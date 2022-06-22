
// Allows QGlobalStatic to work on this translation unit
#define _LOG_CTOR_ACCESS_ public

#include "AppMessages.h"
#include "QGCApplication.h"
#include "SettingsManager.h"
#include "AppSettings.h"

#include <QStringListModel>
#include <QtConcurrent>
#include <QTextStream>

#include "QDebug"

Q_GLOBAL_STATIC(AppLogModel, debug_model)

static QtMessageHandler old_handler;

/* 需求（目的）：生成log.txt日志文件，
 * 记录详细日志信息（包括等级、所在文件、所在行号、描述信息、产生时间等）,
 * 以便于快速跟踪、定位。 */

void outputMessage(QtMsgType type,
				   const QMessageLogContext &context,
				   const QString &msg)
{
	static QMutex mutex;
	mutex.lock();

	QString text;
	switch(type)
	{
		//	enum QtMsgType {
		//	QtDebugMsg, QtWarningMsg, QtCriticalMsg,
		//	QtFatalMsg, QtInfoMsg, QtSystemMsg = QtCriticalMsg };
		case QtDebugMsg:
			text = QString("Debug:");
			break;
		case QtWarningMsg:
			text = QString("Warning:");
			break;
		case QtCriticalMsg:
			text = QString("Critical:");
			break;
		case QtFatalMsg:
			text = QString("Fatal:");
	}
	QString context_info = QString("File:(%1) Line:(%2)")
			.arg(QString(context.file)).arg(context.line);
	QString current_date_time =
			QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss ddd");
	QString current_date = QString("(%1)").arg(current_date_time);
	QString message = QString("%1 %2 %3 %4").arg(text)
			.arg(context_info).arg(msg).arg(current_date);
	QFile file("log.txt");
	file.open(QIODevice::WriteOnly | QIODevice::Append);
	QTextStream text_stream(&file);
	text_stream << message << "\r\n";
	file.flush();
	file.close();

	mutex.unlock();
}

static void msgHandler(QtMsgType type,
					   const QMessageLogContext &context,
					   const QString &msg)
{
	//	enum QtMsgType {
	//	QtDebugMsg, QtWarningMsg, QtCriticalMsg,
	//	QtFatalMsg, QtInfoMsg, QtSystemMsg = QtCriticalMsg };
	const char symbols[] = { 'D', 'E', '!', 'X', 'I' };
	QString output = QString("[%1] at %2:%3 - \"%4\"")
			.arg(symbols[type]).arg(context.file).arg(context.line).arg(msg);
	// Avoid recursion
	if (!QString(context.category).startsWith("qt.quick")) {
		debug_model->log(output); // 生成日志信息
	}
	if (old_handler != nullptr) {
		old_handler(type, context, msg);
	}
	if( type == QtFatalMsg ) abort(); // 致命错误
}

void AppMessages::installHandler() // 重定向 qDebug()、qWarning()等宏的处理
{
	/* 一个完整的程序应该可以是知其然并知其所以然。所以在程序的运行过程中，
	 * 记录一些必要的日志可以知道程序当前的运行状态，也可以在程序运行出错后，快速定位到错误的位置。
	 * 在Qt开发过程当中经常使用 qDebug 等一些输出来调试程序，但是到了正式发布的时候，
	 * 都会被注释或者删除，采用日志输出来代替
	 * 在C++ API changes中提到：Qt::qDebug()、Qt::qWarning()、Qt::qCritical()、Qt::qFatal()
	 * 被改变为宏来跟踪源代码的消息来源。被打印的信息可以被配置（用于缺省消息处理程序），
	 * 通过设置该新的环境变量 QT_MESSAGE_PATTERN。
	 * Qt::qInstallMsgHandler()已过时，因此建议使用Qt::qInstallMessageHandler()来代替。
	Qt5自带一个Qt::qInstallMessageHandler()（Qt4为Qt::qInstallMsgHandler()）
	来重定向 qDebug()、qWarning()等宏的处理 */
	old_handler = qInstallMessageHandler(msgHandler);
	/** 打印日志到文件中 */
#if 0
	// qDebug：		调试信息
	// qWarning：	警告信息
	// qCritical：	严重错误
	// qFatal：		致命错误
	qDebug("调试信息 qDebug(): This is a debug message");
	qWarning("警告信息 qWarning(): This is a warning message");
	qCritical("严重错误 qCritical(): This is a critical message");
	qFatal("致命错误 qFatal(): This is a fatal message");
#endif
	// Force creation of debug model on installing thread
	//	Q_UNUSED(*debug_model);
}

AppLogModel *AppMessages::getModel()
{
	return debug_model;
}

AppLogModel::AppLogModel() : QStringListModel()
{
#ifdef __mobile__
	Qt::ConnectionType contype = Qt::QueuedConnection;
#else
	Qt::ConnectionType contype = Qt::AutoConnection;
#endif
	connect(this, &AppLogModel::emitLog, this, &AppLogModel::threadsafeLog, contype);
}

void AppLogModel::writeMessages(const QString dest_file)
{
	const QString writebuffer(stringList().join('\n').append('\n'));

	QtConcurrent::run([dest_file, writebuffer] {
		emit debug_model->writeStarted();
		bool success = false;
		QFile file(dest_file);
		if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
			QTextStream out(&file);
			out << writebuffer;
			success = out.status() == QTextStream::Ok;
		} else {
			qWarning() << "AppLogModel::writeMessages write failed:" << file.errorString();
		}
		emit debug_model->writeFinished(success);
	});
}

void AppLogModel::log(const QString message) // 信号: 生成日志信息
{
	emit debug_model->emitLog(message);
}

void AppLogModel::threadsafeLog(const QString message)// 槽函数: 生成日志信息
{
	const int line = rowCount();
	insertRows(line, 1);//插入 行
	setData(index(line), message, Qt::DisplayRole);

	if (qgcApp() && qgcApp()->logOutput() && _logFile.fileName().isEmpty()) {
		zcq_debug_echo(__FILE__, __func__, __LINE__,
					   "==== _logFile.fileName().isEmpty(): "
					   << _logFile.fileName().isEmpty() << endl
					   << "==== qgcApp()->logOutput(): "
					   << qgcApp()->logOutput() );
		QGCToolbox* toolbox = qgcApp()->toolbox();
		// Be careful of toolbox not being open yet
		if (toolbox) {
			QString saveDirPath =
					qgcApp()->toolbox()->settingsManager()->appSettings()->crashSavePath();
			QDir saveDir(saveDirPath);
			QString saveFilePath =
					saveDir.absoluteFilePath(QStringLiteral("QGCConsole.log"));

			_logFile.setFileName(saveFilePath);
			if (!_logFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
				qgcApp()->showMessage(tr("Open console log output file failed %1 : %2").arg(_logFile.fileName()).arg(_logFile.errorString()));
			}
		}
	}
	if (_logFile.isOpen()) {
		zcq_debug_echo(__FILE__, __func__, __LINE__, "重定向 qDebug()");
		QTextStream out(&_logFile);
		out << message << "\n";
		_logFile.flush();
	}
}
