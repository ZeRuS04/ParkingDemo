#include "utils_p.h"

#include <QtCore/qdatetime.h>
#include <QtCore/qmath.h>

QT_BEGIN_NAMESPACE

ColorUtils::ColorUtils(QObject *parent)
    : QObject(parent)
{
}

QVector4D ColorUtils::color2hsva(const QColor &color) const
{
    qreal h, s, v, a;
    color.getHsvF(&h, &s, &v, &a);
    return QVector4D(h, s, v, a);
}

QVector4D ColorUtils::color2rgba(const QColor &color) const
{
    qreal r, g, b, a;
    color.getRgbF(&r, &g, &b, &a);
    return QVector4D(r, g, b, a);
}

QVector4D ColorUtils::rgba2hsva(const QVector4D &rgba) const
{
    qreal h, s, v, a;
    QColor::fromRgbF(rgba.x(), rgba.y(), rgba.z(), rgba.z()).getHsvF(&h, &s, &v, &a);
    return QVector4D(h, s, v, a);
}

QVector4D ColorUtils::hsva2rgba(const QVector4D &hsva) const
{
    qreal r, g, b, a;
    QColor::fromHsvF(hsva.x(), hsva.y(), hsva.z(), hsva.z()).getRgbF(&r, &g, &b, &a);
    return QVector4D(r, g, b, a);
}


MathUtils::MathUtils(QObject *parent)
    : QObject(parent)
{
}

qreal MathUtils::pi2() const
{
    return 2.0 * M_PI;
}

qreal MathUtils::clamp(qreal value, qreal min, qreal max) const
{
    return std::max(min, std::min(value, max));
}

/*!
    Linearly projects a value \a x from [\a xmin, \a xmax] into [\a ymin, \a ymax].
*/
qreal MathUtils::projectValue(qreal x, qreal xmin, qreal xmax, qreal ymin, qreal ymax) const
{
    return ((x - xmin) * ymax - (x - xmax) * ymin) / (xmax - xmin);
}

qreal MathUtils::normalizedAngleRad(qreal radians) const
{
    return qreal(int((2.0 * M_PI + radians) * 1000000.0) % int(2.0 * M_PI * 1000000.0)) / 1000000.0;
}

qreal MathUtils::normalizedAngleDeg(qreal degrees) const
{
    return (360 + int(degrees)) % 360 + (degrees - int(degrees));
}

/*!
    Converts the angle \a degrees to radians.
*/
qreal MathUtils::degToRad(qreal degrees) const
{
    return degrees * qreal(M_PI / 180.0);
}

/*!
    Converts the angle \a degrees to radians.

    This function assumes that the angle origin (0) is north, as this
    is the origin used by all of the Extras. The angle
    returned will have its angle origin (0) pointing east, in order to be
    consistent with standard angles used by \l {QtQuick::Canvas}{Canvas},
    for example.
*/
qreal MathUtils::degToRadOffset(qreal degrees) const
{
    return (degrees - 90.0) * qreal(M_PI / 180.0);
}

/*!
    Converts the angle \a radians to degrees.
*/
qreal MathUtils::radToDeg(qreal radians) const
{
    return radians * qreal(180.0 / M_PI);
}

/*!
    Converts the angle \a radians to degrees.

    This function assumes that the angle origin (0) is east; as is standard for
    mathematical operations using radians (this origin is used by
    \l {QtQuick::Canvas}{Canvas}, for example). The angle returned in degrees
    will have its angle origin (0) pointing north, which is what the extras
    expect.
*/
qreal MathUtils::radToDegOffset(qreal radians) const
{
    return radians * qreal(180.0 / M_PI) + 90.0;
}

/*!
    Returns the top left position of the item of width \a width and height \a height
    if it were centered along a circle of width \a circleWidth and height \a circleHeight
    according to \a angleOnCircle and \a distanceAlongRadius.

    \a angleOnCircle is from 0.0 to pi2.
    \a distanceAlongRadius is from 0.0 to 1.0.
*/
QPointF MathUtils::centerAlongCircle(qreal circleWidth, qreal circleHeight, qreal width, qreal height, qreal angleOnCircle, qreal distanceAlongRadius) const
{
    return QPointF(((circleWidth - width) / 2) * (1 + distanceAlongRadius * std::cos(angleOnCircle)),
                   ((circleHeight - height) / 2) * (1 + distanceAlongRadius * std::sin(-angleOnCircle)));
}

/*!
    Returns \a number rounded to the nearest even integer.
*/
qreal MathUtils::roundEven(qreal number) const
{
    int rounded = qRound(number);
    return rounded + rounded % 2;
}


TimeUtils::TimeUtils(QObject *parent)
    : QObject(parent)
{
}

/*!
    Converts the time represented in milliseconds \a msecs to a time string,
    accordingly to a given format \a format and spec \a spec.
*/
QString TimeUtils::msecToString(qint64 msecs, const QString &format, Qt::TimeSpec spec) const
{
    const QDateTime dt = QDateTime::fromMSecsSinceEpoch(msecs, spec);
    return dt.toString(format);
}

/*!
    Parses time represented in the string \a string using the \a format given,
    and returns the number of milliseconds for this resulting timein a spec \a spec.
*/
qint64 TimeUtils::stringToMsec(const QString &string, const QString &format, Qt::TimeSpec spec) const
{
    QDateTime dt = QDateTime::fromString(string, format);
    dt = dt.toTimeSpec(spec);
    return dt.toMSecsSinceEpoch();
}

QT_END_NAMESPACE
