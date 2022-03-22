/*
 * Copyright 2018 by Aditya Mehra <aix.m@outlook.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#pragma once

#include <QObject>
#include <QColor>
#include <QSettings>
#include "globalsettings.h"
 
#ifdef KirigamiLegacy
#include <Kirigami2/PlatformTheme>
#else
#include <Kirigami/PlatformTheme>
#endif

class GlobalSettings;
class QSettings;
class ColorScheme : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor primaryColor READ primaryColor WRITE setPrimaryColor NOTIFY primaryColorChanged)
    Q_PROPERTY(QColor secondaryColor READ secondaryColor WRITE setSecondaryColor NOTIFY secondaryColorChanged)
    Q_PROPERTY(QColor textColor READ textColor WRITE setTextColor NOTIFY textColorChanged)
    Q_PROPERTY(bool useCustomTheme READ useCustomTheme WRITE setUseCustomTheme NOTIFY useCustomThemeChanged)

public:
    explicit ColorScheme(QObject *parent = Q_NULLPTR);

public Q_SLOTS:
    QColor primaryColor() const;
    void setPrimaryColor(const QColor &primaryColor);
    QColor secondaryColor() const;
    void setSecondaryColor(const QColor &secondaryColor);
    QColor textColor() const;
    void setTextColor(const QColor &textColor);
    bool useCustomTheme() const;
    void setUseCustomTheme(bool useCustomTheme);

    void updateColorConfig();
    void syncConfig();

Q_SIGNALS:
    void primaryColorChanged();
    void secondaryColorChanged();
    void textColorChanged();
    void useCustomThemeChanged();

private:
    QColor m_primaryColor = QColor(Qt::white);
    QColor m_secondaryColor = QColor(Qt::black);
    QColor m_textColor = QColor(Qt::black);

    QSettings m_colorSchemeSettings;
    GlobalSettings m_globalSettings;

    Kirigami::PlatformTheme *m_platformTheme;
};
