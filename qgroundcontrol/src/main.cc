
#if 0          /* 不产生 调试信息 */
#define QT_NO_WARNING_OUTPUT
#define QT_NO_MESSAGELOGCONTEXT
#endif

#include <QDebug>

#include "QGC.h"
#include <QtGlobal>
#include <QApplication>
#include <QIcon>
#include <QSslSocket>
#include <QMessageBox>
#include <QProcessEnvironment>
#include <QHostAddress>
#include <QUdpSocket>
#include <QtPlugin>
#include <QStringListModel>
#include "QGCApplication.h"
#include "AppMessages.h"

#ifndef __mobile__
#include "QGCSerialPortInfo.h"
#include "RunGuard.h"
#endif

#ifdef UNITTEST_BUILD
#include "UnitTest.h"
#endif

#ifdef QT_DEBUG
#include "CmdLineOptParser.h"
#ifdef Q_OS_WIN
#include <crtdbg.h>
#endif
#endif

#ifdef QGC_ENABLE_BLUETOOTH
#include <QtBluetooth/QBluetoothSocket>
#endif

#include <iostream>
#include "QGCMapEngine.h"

/* SDL does ugly things to main() */
#ifdef main
#undef main
#endif

#ifndef __mobile__
#ifndef NO_SERIAL_LINK
Q_DECLARE_METATYPE(QGCSerialPortInfo)
#endif
#endif

#ifdef Q_OS_WIN
#include <windows.h>
/// @brief CRT Report Hook installed using _CrtSetReportHook. We install this hook when
/// we don't want asserts to pop a dialog on windows.
int WindowsCrtReportHook(int reportType, char *message, int *returnValue)
{
	Q_UNUSED(reportType);

	std::cerr << message << std::endl; // Output message to stderr
	*returnValue = 0;				   // Don't break into debugger
	return true;					   // We handled this fully ourselves
}
#endif

#if defined(__android__)
#include <jni.h>
#include "JoystickAndroid.h"
#if defined(QGC_ENABLE_PAIRING)
#include "PairingManager.h"
#endif
#if !defined(NO_SERIAL_LINK)
#include "qserialport.h"
#endif

static jobject _class_loader = nullptr;
static jobject _context = nullptr;

//-----------------------------------------------------------------------------
extern "C"
{
void gst_amc_jni_set_java_vm(JavaVM *java_vm);

jobject gst_android_get_application_class_loader(void)
{
	return _class_loader;
}
}

//-----------------------------------------------------------------------------
static void
gst_android_init(JNIEnv *env, jobject context)
{
	jobject class_loader = nullptr;

	jclass context_cls = env->GetObjectClass(context);
	if (!context_cls)
	{
		return;
	}

	jmethodID get_class_loader_id = env->GetMethodID(context_cls, "getClassLoader", "()Ljava/lang/ClassLoader;");
	if (env->ExceptionCheck())
	{
		env->ExceptionDescribe();
		env->ExceptionClear();
		return;
	}

	class_loader = env->CallObjectMethod(context, get_class_loader_id);
	if (env->ExceptionCheck())
	{
		env->ExceptionDescribe();
		env->ExceptionClear();
		return;
	}

	_context = env->NewGlobalRef(context);
	_class_loader = env->NewGlobalRef(class_loader);
}

//-----------------------------------------------------------------------------
static const char kJniClassName[]{"org/mavlink/qgroundcontrol/QGCActivity"};

void setNativeMethods(void)
{
	JNINativeMethod javaMethods[]{
		{"nativeInit", "()V", reinterpret_cast<void *>(gst_android_init)}};

	QAndroidJniEnvironment jniEnv;
	if (jniEnv->ExceptionCheck())
	{
		jniEnv->ExceptionDescribe();
		jniEnv->ExceptionClear();
	}

	jclass objectClass = jniEnv->FindClass(kJniClassName);
	if (!objectClass)
	{
		qWarning() << "Couldn't find class:" << kJniClassName;
		return;
	}

	jint val = jniEnv->RegisterNatives(objectClass, javaMethods, sizeof(javaMethods) / sizeof(javaMethods[0]));

	if (val < 0)
	{
		qWarning() << "Error registering methods: " << val;
	}
	else
	{
		qDebug() << "Main Native Functions Registered";
	}

	if (jniEnv->ExceptionCheck())
	{
		jniEnv->ExceptionDescribe();
		jniEnv->ExceptionClear();
	}
}

//-----------------------------------------------------------------------------
jint JNI_OnLoad(JavaVM *vm, void *reserved)
{
	Q_UNUSED(reserved);

	JNIEnv *env;
	if (vm->GetEnv(reinterpret_cast<void **>(&env), JNI_VERSION_1_6) != JNI_OK)
	{
		return -1;
	}

	setNativeMethods();

#if defined(QGC_GST_STREAMING)
	// Tell the androidmedia plugin about the Java VM
	gst_amc_jni_set_java_vm(vm);
#endif

#if !defined(NO_SERIAL_LINK)
	QSerialPort::setNativeMethods();
#endif

	JoystickAndroid::setNativeMethods();

#if defined(QGC_ENABLE_PAIRING)
	PairingManager::setNativeMethods();
#endif

	return JNI_VERSION_1_6;
}
#endif

//-----------------------------------------------------------------------------
#ifdef __android__
#include <QtAndroid>
bool checkAndroidWritePermission()
{
	QtAndroid::PermissionResult r = QtAndroid::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
	if (r == QtAndroid::PermissionResult::Denied)
	{
		QtAndroid::requestPermissionsSync(QStringList() << "android.permission.WRITE_EXTERNAL_STORAGE");
		r = QtAndroid::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
		if (r == QtAndroid::PermissionResult::Denied)
		{
			return false;
		}
	}
	return true;
}
#endif

/**
 * @brief Starts the application
 *
 * @param argc Number of commandline arguments
 * @param argv Commandline arguments
 * @return exit code, 0 for normal exit and !=0 for error cases
 */

int main(int argc, char *argv[])
{

	std::string shellcmd="sudo rm -rf /home/zcq/.cache/zcq_QGround*;"
						 "sudo rm -rf /home/zcq/.cache/QGround*;"
						 "sudo rm -rf /home/zcq/.cache/qt_compose_cache*;"
						 "sudo rm -rf /home/zcq/.cache/QGCMapCache*;"
						 "sudo rm -rf /home/zcq/文档/zcq_QGroundControl*;"
						 "sudo rm -rf /home/zcq/文档/QGroundControl*;"
						 "sudo rm -rf /home/zcq/.config/*QGroundControl.org";
	int zcqval=system(shellcmd.data());
	if (zcqval!=0) {
		qDebug() << "system() error";
		return -1;
	}
	shellcmd.clear();

#ifndef __mobile__
#if 0
	/** 使用 共享内存+信号量 来控制一次启动
 移动平台运行互斥管理 ：通过共享内存方式来进行程序互斥操作 **/
	RunGuard guard("QGroundControlRunGuardKey");
	if (!guard.tryToRun())
	{
		zcq_debug_echo(__FILE__, __func__, __LINE__, "runing !!!");
#if 0   /* 弹窗 */
		// QApplication is necessary to use QMessageBox
		QApplication errorApp(argc, argv);
		QMessageBox::critical(nullptr, QObject::tr("Error"),
							  QObject::tr(
								  "A second instance of %1 is already running. "
								  "Please close the other instance and try again."
								  ).arg(QGC_APPLICATION_NAME)  );
#endif
		return -1;
	}
#endif
#endif

	QGC::initTimer();	//-- Record boot time 记录启动时间

#ifdef Q_OS_UNIX
	//Force writing to the console on UNIX/BSD devices
	// 对于unix平台强制写入console控制台
	if (!qEnvironmentVariableIsSet("QT_LOGGING_TO_CONSOLE"))
		qputenv("QT_LOGGING_TO_CONSOLE", "1");
#endif

	/** 注册消息处理程序 */
	AppMessages::installHandler(); // 重定向 qDebug()、qWarning()等宏的处理
	zcq_debug_echo(__FILE__, __func__, __LINE__, "重定向 qDebug()");
	AppLogModel::log("生成日志信息"); // 生成日志信息

#ifdef Q_OS_MAC
#ifndef __ios__
	// Prevent Apple's app nap from screwing us over
	// tip: the domain can be cross-checked on the command line with <defaults domains>
	QProcess::execute("defaults write org.qgroundcontrol.qgroundcontrol NSAppSleepDisabled -bool YES");
#endif
#endif

#ifdef Q_OS_WIN
	// Set our own OpenGL buglist
	qputenv("QT_OPENGL_BUGLIST", ":/opengl/resources/opengl/buglist.json");

	// Allow for command line override of renderer
	for (int i = 0; i < argc; i++)
	{
		const QString arg(argv[i]);
		if (arg == QStringLiteral("-angle"))
		{
			QCoreApplication::setAttribute(Qt::AA_UseOpenGLES);
			break;
		}
		else if (arg == QStringLiteral("-swrast"))
		{
			QCoreApplication::setAttribute(Qt::AA_UseSoftwareOpenGL);
			break;
		}
	}
#endif

	/** 以下是注册一些类型 枚举之类的到QML中使用 */
	/* The following calls to qRegisterMetaType are done to silence debug output
	which warns that we use these types in signals,
	and without calling qRegisterMetaType we can't queue these signals.
	In general we don't queue these signals,
	but we do what the warning says anyway to silence the debug output.
	对qRegisterMetaType执行以下调用以使调试输出静音警告我们在信号中使用这些类型，
	如果不调用qRegisterMetaType，我们就无法对这些信号进行排队。
	一般来说，我们不会将这些信号排队，但是我们还是按照警告所说的做，以使调试输出静音。 */
#ifndef NO_SERIAL_LINK
	qRegisterMetaType<QSerialPort::SerialPortError>();//函数注册类型
#endif
#ifdef QGC_ENABLE_BLUETOOTH
	qRegisterMetaType<QBluetoothSocket::SocketError>();
	qRegisterMetaType<QBluetoothServiceInfo>();
#endif
	qRegisterMetaType<QAbstractSocket::SocketError>();//函数注册类型
#ifndef __mobile__
#ifndef NO_SERIAL_LINK
	qRegisterMetaType<QGCSerialPortInfo>();//函数注册类型
#endif
#endif

	// We statically link our own QtLocation plugin

#ifdef Q_OS_WIN
	// In Windows, the compiler doesn't see the use of the class created by Q_IMPORT_PLUGIN
#pragma warning(disable : 4930 4101)
#endif

	Q_IMPORT_PLUGIN(QGeoServiceProviderFactoryQGC)//引入静态插件

	/* true: running unit tests, false: normal app */
	bool runUnitTests = false; // Run unit tests 是否运行单元测试 false: normal app

	/** DEBUG 模式下进行的一些参数设置 */
#ifdef QT_DEBUG
	/** We parse a small set of command line options
	here prior to QGCApplication in order to handle the ones
	which need to be handled before a QApplication object is started. */
	bool stressUnitTests = false;	  // Stress test unit tests
	bool quietWindowsAsserts = false; // Don't let asserts pop dialog boxes

	QString unitTestOptions;
	CmdLineOpt_t rgCmdLineOptions[] = {
		{ "--unittest",             &runUnitTests,          &unitTestOptions },
		{ "--unittest-stress",      &stressUnitTests,       &unitTestOptions },
		{ "--no-windows-assert-ui", &quietWindowsAsserts,   nullptr },
		// Add additional command line option flags here
	};

	ParseCmdLineOptions(argc, argv, rgCmdLineOptions, sizeof(rgCmdLineOptions)/sizeof(rgCmdLineOptions[0]), false);
	if (stressUnitTests) {
		runUnitTests = true;
	}

	if (quietWindowsAsserts)
	{
#ifdef Q_OS_WIN
		_CrtSetReportHook(WindowsCrtReportHook);
#endif
	}

#ifdef Q_OS_WIN
	if (runUnitTests)
	{
		// Don't pop up Windows Error Reporting dialog when app crashes. This prevents TeamCity from
		// hanging.
		DWORD dwMode = SetErrorMode(SEM_NOGPFAULTERRORBOX);
		SetErrorMode(dwMode | SEM_NOGPFAULTERRORBOX);
	}
#endif

#endif // QT_DEBUG

	QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);

	/** QGC App 程序真正的入口地方 QGCApplication(argc, argv, false) */
	QGCApplication *app = new QGCApplication(argc, argv, runUnitTests);
	Q_CHECK_PTR(app); // Q_CHECK_PTR 宏 做了一个指针合法校验 很常用
	if (app->isErrorState())
	{
		zcq_debug_echo(__FILE__, __FUNCTION__, __LINE__, "app->isErrorState()" );
		app->exec();//整个程序就运行
		return -1;
	}

#ifdef Q_OS_LINUX
	/* 设置(app)应用程序图标和可执行程序图标 */
	//QApplication::setWindowIcon(QIcon(":/res/resources/icons/qgroundcontrol.ico"));
	QApplication::setWindowIcon(QIcon(":/res/resources/icons/Pikachu.ico"));
#endif /* Q_OS_LINUX */

	/* qRegisterMetaType中似乎存在线程问题，这可能导致它抛出关于重复类型转换器的qWarning。
这是由Qt代码中的争用条件引起的。仍在与他们一起跟踪错误。目前，我们在这里注册给我们带来问题的类型，
而我们只有主线程。这应该是正确的防止它在代码中稍后遇到竞争条件。
	防止 qRegisterMetaType 注册线程 抛出异常特殊操作 */
	qRegisterMetaType<QList<QPair<QByteArray, QByteArray>>>();

	app->_initCommon(); // GC app 注册C++类到QML元对象中给QML使用

	//-- Initialize Cache System
	getQGCMapEngine()->init();//初始化QGC地图引擎

	int exitCode = 0;

	/** 单元测试参数设置 */
#ifdef UNITTEST_BUILD
	if (runUnitTests)
	{
		for (int i = 0; i < (stressUnitTests ? 20 : 1); i++)
		{
			if (!app->_initForUnitTests())
			{
				return -1;
			}

			// Run the test
			int failures = UnitTest::run(unitTestOptions);
			if (failures == 0)
			{
				qDebug() << "ALL TESTS PASSED";
				exitCode = 0;
			}
			else
			{
				qDebug() << failures << " TESTS FAILED!";
				exitCode = -failures;
				break;
			}
		}
	}
	else
#endif

	{
#ifdef __android__
		checkAndroidWritePermission();
#endif
		/* _initForNormalAppBoot 初始化 MainWindow 主界面以及相关硬件设备 遥感之类的
		 *  最后同步 Settings 配置文件 */
		if (!app->_initForNormalAppBoot())
		{
			return -1;
		}
		zcq_debug_echo(__FILE__, __FUNCTION__, __LINE__, "整个程序就运行起来了" );
		exitCode = app->exec(); // 整个程序就运行起来了
	}

	app->_shutdown();
	delete app;
	//-- Shutdown Cache System
	destroyMapEngine();
	qDebug() << "After app delete";

	return exitCode;
}
