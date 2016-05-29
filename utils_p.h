#ifndef UTILS_P_H
#define UTILS_P_H

#include <QtCore/qobject.h>
#include <QtCore/qrect.h>

#include <QtGui/qcolor.h>
#include <QtGui/qvector4d.h>

QT_BEGIN_NAMESPACE

class ColorUtils : public QObject
{
    Q_OBJECT

public:
    explicit ColorUtils(QObject *parent = Q_NULLPTR);

    Q_INVOKABLE QVector4D color2hsva(const QColor &color) const;
    Q_INVOKABLE QVector4D color2rgba(const QColor &color) const;

    Q_INVOKABLE QVector4D rgba2hsva(const QVector4D &rgba) const;
    Q_INVOKABLE QVector4D hsva2rgba(const QVector4D &hsva) const;
};


class MathUtils : public QObject
{
    Q_OBJECT
    Q_PROPERTY(qreal pi2 READ pi2 CONSTANT)

public:
    explicit MathUtils(QObject *parent = Q_NULLPTR);

    qreal pi2() const;

    Q_INVOKABLE qreal clamp(qreal value, qreal min, qreal max) const;

    Q_INVOKABLE qreal projectValue(qreal x, qreal xmin, qreal xmax, qreal ymin, qreal ymax) const;

    Q_INVOKABLE qreal normalizedAngleRad(qreal radians) const;
    Q_INVOKABLE qreal normalizedAngleDeg(qreal degrees) const;

    Q_INVOKABLE qreal degToRad(qreal degrees) const;
    Q_INVOKABLE qreal degToRadOffset(qreal degrees) const;
    Q_INVOKABLE qreal radToDeg(qreal radians) const;
    Q_INVOKABLE qreal radToDegOffset(qreal radians) const;

    Q_INVOKABLE QPointF centerAlongCircle(qreal xCenter, qreal yCenter,
                                          qreal width, qreal height, qreal angleOnCircle, qreal distanceAlongRadius) const;
    Q_INVOKABLE qreal roundEven(qreal number) const;
    Q_INVOKABLE QPointF intersect(QPointF p1, QPointF p2, QPointF p3, QPointF p4);
    Q_INVOKABLE double lineLength(QPointF p1, QPointF p2);

};


class TimeUtils : public QObject
{
    Q_OBJECT

public:
    explicit TimeUtils(QObject *parent = Q_NULLPTR);

    Q_INVOKABLE QString msecToString(qint64 msecs, const QString &format, Qt::TimeSpec spec = Qt::UTC) const;
    Q_INVOKABLE qint64 stringToMsec(const QString &string, const QString &format, Qt::TimeSpec spec = Qt::UTC) const;
};

QT_END_NAMESPACE

#endif // UTILS_P_H
