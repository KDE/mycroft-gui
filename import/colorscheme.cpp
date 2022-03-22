#include "colorscheme.h"
#include <QSettings>


// Version checking required as some distributions ship older Kirigami Packages
// Maintain compatibility
#ifdef KirigamiLegacy
#include <Kirigami2/KirigamiPluginFactory>
#else
#include <Kirigami/KirigamiPluginFactory>
#endif

ColorScheme::ColorScheme(QObject *parent) 
    : QObject(parent)
{
    // Usage:
    // Mycroft.ColorScheme.primaryColor, Mycroft.ColorScheme.secondaryColor, Mycroft.ColorScheme.textColor

    // Initialize an instance of the Kirigami Plugin as priority
    // Set a pointer as soon as the platform theme is available
    // Always before updating color config.

    // Once initialized it does not get called again.
    auto plugin = Kirigami::KirigamiPluginFactory::findPlugin();
    if(plugin) {
        auto platformTheme = plugin->createPlatformTheme(this);
        if(platformTheme) {
            m_platformTheme = platformTheme;
        } else {
            qWarning() << "Failed to load PlatformTheme Plugin falling back to custom theme";
            m_platformTheme = nullptr;
            setUseCustomTheme(true);
        }
    }
    updateColorConfig();
}

QColor ColorScheme::primaryColor() const
{
    return m_primaryColor;
}

void ColorScheme::setPrimaryColor(const QColor &primaryColor)
{
    if (m_primaryColor == primaryColor)
        return;

    m_colorSchemeSettings.setValue(QStringLiteral("primaryColor"), primaryColor.name(QColor::HexArgb));
    m_primaryColor = primaryColor;
    emit primaryColorChanged();
}

QColor ColorScheme::secondaryColor() const
{
    return m_secondaryColor;
}

void ColorScheme::setSecondaryColor(const QColor &secondaryColor)
{
    if (m_secondaryColor == secondaryColor)
        return;
    
    m_colorSchemeSettings.setValue(QStringLiteral("secondaryColor"), secondaryColor.name(QColor::HexArgb));
    m_secondaryColor = secondaryColor;
    emit secondaryColorChanged();
}

QColor ColorScheme::textColor() const
{
    return m_textColor;
}

void ColorScheme::setTextColor(const QColor &textColor)
{
    if (m_textColor == textColor)
        return;
    
    m_colorSchemeSettings.setValue(QStringLiteral("textColor"), textColor.name(QColor::HexArgb));
    m_textColor = textColor;
    emit textColorChanged();
}

void ColorScheme::updateColorConfig() 
{
    if (useCustomTheme()) {
        if (m_colorSchemeSettings.contains(QLatin1String("primaryColor"))) {
                m_primaryColor = m_colorSchemeSettings.value(QLatin1String("primaryColor"), QColor(Qt::white)).value<QColor>();
                emit primaryColorChanged();
        }
        if (m_colorSchemeSettings.contains(QLatin1String("secondaryColor"))) {
                m_secondaryColor = m_colorSchemeSettings.value(QLatin1String("secondaryColor"), QColor(Qt::black)).value<QColor>();
                emit secondaryColorChanged();
        }
        if (m_colorSchemeSettings.contains(QLatin1String("textColor"))) {
                m_textColor = m_colorSchemeSettings.value(QLatin1String("textColor"), QColor(Qt::black)).value<QColor>();
                emit textColorChanged();
        }
    } else {
        if (m_platformTheme) {
            m_platformTheme->setColorSet(Kirigami::PlatformTheme::ColorSet::Complementary);
            setPrimaryColor(m_platformTheme->backgroundColor());
            setSecondaryColor(m_platformTheme->highlightColor());
            setTextColor(m_platformTheme->textColor());
        }
    }
}

void ColorScheme::syncConfig()
{
    m_colorSchemeSettings.sync();
    updateColorConfig();
}

bool ColorScheme::useCustomTheme() const
{
    // Custom color theme is off by default and needs to be explicitly enabled
    return m_colorSchemeSettings.value(QStringLiteral("useCustomTheme"), false).toBool();
}

void ColorScheme::setUseCustomTheme(bool useCustomTheme)
{
    if (ColorScheme::useCustomTheme() == useCustomTheme) {
        return;
    }

    m_colorSchemeSettings.setValue(QStringLiteral("useCustomTheme"), useCustomTheme);
    syncConfig();
    emit useCustomThemeChanged();
}
