
#ifndef Zcq_Debug_line
#define Zcq_Debug_line

#include <QObject>
#include "QDebug" 

#if 0
/** zcq_debug_echo(__FILE__, __FUNCTION__, __LINE__, "zcq"); **/
//#define zcq_debug_echo(file, func, line, str)
#define zcq_debug_echo(file, func, line, str)  do { \
	qDebug() << "<<<< file : " << file << "; func: " << func << "()"\
	<< "; line[ " << line << " ] " << endl << str; \
	} while(0);
#define zcq_debug(str) zcq_debug_echo(__FILE__, __func__, __LINE__, str)
#else
#define zcq_debug_echo(file, func, line, str)
#define zcq_debug(str)
#endif

#define zcq_debug_print0(str) qDebug() << str;
#define zcq_debug_print1(file, func, line, str)  do { \
	qDebug() << "<<<< file : " << file << "; func: " << func << "()"\
	<< "; line[ " << line << " ] " << endl << str; \
	} while(0);
class Zcq_debug_class : public QObject
{
	Q_OBJECT
public:
	Zcq_debug_class(){}
	~Zcq_debug_class(){}
	Q_INVOKABLE bool flag() { return true; }
	Q_INVOKABLE void echo0(const QString str) {
		if(this->flag()) zcq_debug_print0(str.data());
	}
	Q_INVOKABLE void echo1(const char *file, const char *func, const int &line, const QString str) {
		if(this->flag()) zcq_debug_print1(file, func, line, str.data());
	}
};
//qmlRegisterType<QGCPalette> ("QGroundControl.Palette", 1, 0, "QGCPalette");

#endif


