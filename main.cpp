#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <utils_p.h>

static QObject *mathUtilsSingleton(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    MathUtils *utils = new MathUtils();
    return utils;
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("ESin");
    app.setOrganizationDomain("esin.loc");
    app.setApplicationName("Parking Demo");
    QQmlApplicationEngine engine;
    qmlRegisterSingletonType<MathUtils>("My.Utils", 1, 0, "MathUtils", mathUtilsSingleton);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
