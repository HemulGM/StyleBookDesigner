# Контролы FireMonkey и используемые элементы стиля

Анализ локальных исходников **Delphi 13 / RAD Studio 37.0**, выполнен **5 октября 2026 года**. Каталог относится к установленной версии, включая новый текстовый редактор FMX.

Исходники: `G:\Program Files (x86)\Embarcadero\Studio\37.0\source\fmx`. Просмотрены 322 Pascal-модуля каталога FMX: вызовы FindStyleResource/FindAndCloneStyleResource, ApplyStyle, вспомогательные методы, константы/массивы имён, StylesData и регистрации представлений. Основной каталог содержит 167 базовых, пользовательских и внутренних 2D styled-классов. Платформенные представления и инфраструктурные обращения вынесены отдельно.

Документ описывает **имена, запрашиваемые кодом**, а не все декоративные объекты конкретного файла .style. Многие части необязательны: проверяются наличие и тип, выбираются запасные варианты или создаются служебные объекты. Условные ветви перечислены как возможные обращения. Это статический анализ исходников, не трасса одного запуска.

## Как читать каталог

- Имя части — **StyleName**, а не компонентное Name. Написание сохранено как в исходниках: например, `Content`, `AlternatingRowBackground`, `FullSize`. Совпадающие имена разных регистров объединены только в суммарном списке.
- Краткий каталог содержит суммарный набор найденных обращений с учётом предков и соответствующего styled представления. Для типов, условий и области поиска см. подробные контракты.
- Рядом с каждым именем в кратком каталоге указан класс. В подробных таблицах разделены **проверяемый тип/условие** и **возможные классы**. Если проверяется только интерфейс, конкретный класс не фиксирован; приведены совместимые реализации из FMX. Наследники требуемого класса также допустимы, если сохраняют нужные интерфейсы.
- Несколько типов у одного имени отражают разные проверки и ветви кода. Класс примера не означает обязательность самой части. Пример TPath для стрелки подходит как TControl, но tint потребует отдельного ITintedObject; обычный TPath его не предоставляет.

### Конкретные реализации интерфейсных требований

| Проверяемый интерфейс | Совместимые классы FMX | Объявление реализации |
| --- | --- | --- |
| `IFontObject` | `TFontObject` | [FMX.Graphics.pas:1307](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Graphics.pas:1307>) |
| `IBrushObject` | `TBrushObject` | [FMX.Graphics.pas:1284](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Graphics.pas:1284>) |
| `ITextSettings + ICaption` | `TText`, `TStyleTextObject`, `TLabel` | [FMX.Objects.pas:536](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Objects.pas:536>) |
| `ITintedObject` | `TTintedStyleObject`, `TTintedButtonStyleObject` | [FMX.Styles.Objects.pas:291](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Styles.Objects.pas:291>) |
| `ITintedObject (глиф)` | `TTintedGlyph` | [FMX.ImgList.pas:534](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ImgList.pas:534>) |
| `IDrawableObject` | `TStyleObject`, `TCheckStyleObject`, `TStyleTextObject` | [FMX.Styles.Objects.pas:87](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Styles.Objects.pas:87>) |
| `IAlignableObject` | `TControl и потомки` | [FMX.Controls.pas:251](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Controls.pas:251>) |
| `ISkStyleTextObject` | `TSkStyleTextObject` | [FMX.Skia.pas:884](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Skia.pas:884>) |
| `ITouchAnimationObject` | `TActiveStyleObject` | [FMX.Styles.Objects.pas:319](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Styles.Objects.pas:319>) |

- `Self` означает ресурс самого контрола/его представления. Поиск внутри FTrack, активной ветви вкладки или стиля строки отмечен отдельно.
- У TPresentedControl учитываются **две цепочки**: наследование контрола и наследование TStyled* presentation. Основной каталог описывает styled вариант; native может иметь другой контракт.
- Наследуемые реализации ApplyStyle в разобранных семействах вызываются через inherited. Переопределённый FindTextObject и поиски в других объектах требуют отдельной проверки, а не простого объединения строковых литералов.
- Popup-меню редакторов, временный флажок таблицы и оконная рамка имеют отдельные области поиска. Их имена нельзя требовать как детей editstyle/memostyle/gridstyle.
- Если часть сама является контролом (например TScrollBar или TPopupBox), она может применять собственный StyleLookup. Её собственный контракт надо смотреть отдельно; это не дополнительные имена частей родительского ресурса.

### Два показательных примера

**TButton** → TCustomButton → TPresentedTextControl → TPresentedControl → TStyledControl. `text` и `foreground` приходят от TPresentedTextControl; TCustomButton добавляет `background`, `glyphstyle`, `icon`. Глиф должен быть TGlyph для Images/ImageIndex; фон и иконка дополнительно проверяются на ITintedObject.

**TEdit** → TCustomEdit → TPresentedControl → TStyledControl; представление: **FMX.Edit.Style.New.TStyledEdit** → TStyledPresentation → TStyledControl. В этой версии **TEdit не ищет `text`**. Набор частей: `buttons`, `leftbuttons`, `prompt`, `content`, `selection`, `foreground`, `font`, `caretcolor`, `leftselectionpoint`, `rightselectionpoint`, `caretpoint`. Последние три находит TInteractiveTextSelectors, вызываемый из ApplyStyle. Вводимый текст рисуется редактором в области содержимого.

## Краткий каталог с учётом наследования

### Базовые классы

| Класс и назначение | Непосредственный предок / представление | Элементы и классы с учётом наследования |
| --- | --- | --- |
| `TStyledControl` — Основа контролов, загружающих FMX-ресурс стиля.<br>[FMX.Controls.pas:931](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Controls.pas:931>) | `TControl` | Фиксированные имена частей не найдены; см. примечания о корне/представлении. |
| `TPresentedControl` — Контрол с отдельным styled или native представлением.<br>[FMX.Controls.Presentation.pas:231](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Controls.Presentation.pas:231>) | `TStyledControl` | Фиксированные имена частей не найдены; см. примечания о корне/представлении. |
| `TTextControl` — База текстовых styled контролов.<br>[FMX.Controls.pas:1317](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Controls.pas:1317>) | `TStyledControl` | `foreground` — `TBrushObject`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TPresentedTextControl` — База текстовых контролов с поддержкой presentation.<br>[FMX.StdCtrls.pas:27](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:27>) | `TPresentedControl` | `foreground` — `TBrushObject`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TPopup` — Всплывающий контейнер с оформляемым фоном.<br>[FMX.Controls.pas:1484](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Controls.pas:1484>) | `TStyledControl` | `background` — `TControl` |
| `TStyledPresentation` — Базовое styled представление TPresentedControl.<br>[FMX.Presentation.Style.pas:25](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Presentation.Style.pas:25>) | `TStyledControl` | Фиксированные имена частей не найдены; см. примечания о корне/представлении. |

**TStyledControl**. Общего обязательного списка частей нет. RequestStyleData/StyleDataChanged принимают путь `имя_объекта.свойство`. GetStyleObject/LookupStyleObject выбирают корневой ресурс; произвольные ключи StylesData зависят от приложения.

**TPresentedControl**. При наличии proxy FindStyleResource передаёт запрос presentation через PM_FIND_STYLE_RESOURCE. Поэтому одного просмотра методов TEdit/TMemo/TGrid недостаточно.


### Кнопки, подписи и панели

| Класс и назначение | Непосредственный предок / представление | Элементы и классы с учётом наследования |
| --- | --- | --- |
| `TPanel` — Панель для дочерних контролов.<br>[FMX.StdCtrls.pas:143](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:143>) | `TPresentedControl` | Фиксированные имена частей не найдены; см. примечания о корне/представлении. |
| `TCalloutPanel` — Панель с выступающим указателем.<br>[FMX.StdCtrls.pas:212](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:212>) | `TPanel` | `Background` — `TCalloutRectangle` |
| `TToolBar` — Панель инструментов.<br>[FMX.StdCtrls.pas:1216](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:1216>) | `TPresentedControl` | Фиксированные имена частей не найдены; см. примечания о корне/представлении. |
| `TStatusBar` — Строка состояния с ручкой изменения размера.<br>[FMX.StdCtrls.pas:1120](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:1120>) | `TPresentedControl` | `sizegrip` — `TControl` |
| `TLabel` — Текстовая подпись.<br>[FMX.StdCtrls.pas:256](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:256>) | `TPresentedTextControl` | `foreground` — `TBrushObject`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TCustomButton` — База кнопок с текстом, глифом и оттенком оформления.<br>[FMX.StdCtrls.pas:395](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:395>) | `TPresentedTextControl` | `background` — `TTintedStyleObject / TTintedButtonStyleObject (ITintedObject)`<br>`foreground` — `TBrushObject`<br>`glyphstyle` — `TGlyph; TTintedGlyph / TTintedStyleObject (ITintedObject)`<br>`icon` — `TControl (ITintedObject)`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TButton` — Обычная кнопка действия.<br>[FMX.StdCtrls.pas:481](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:481>) | `TCustomButton` | `background` — `TTintedStyleObject / TTintedButtonStyleObject (ITintedObject)`<br>`foreground` — `TBrushObject`<br>`glyphstyle` — `TGlyph; TTintedGlyph / TTintedStyleObject (ITintedObject)`<br>`icon` — `TControl (ITintedObject)`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TSpeedButton` — Кнопка панели инструментов, включая состояние нажатия.<br>[FMX.StdCtrls.pas:574](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:574>) | `TCustomButton` | `background` — `TTintedStyleObject / TTintedButtonStyleObject (ITintedObject)`<br>`foreground` — `TBrushObject`<br>`glyphstyle` — `TGlyph; TTintedGlyph / TTintedStyleObject (ITintedObject)`<br>`icon` — `TControl (ITintedObject)`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TCustomCornerButton` — Кнопка с настраиваемыми углами фона.<br>[FMX.StdCtrls.pas:673](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:673>) | `TCustomButton` | `background` — `TTintedStyleObject / TTintedButtonStyleObject (ITintedObject); TRectangle`<br>`foreground` — `TBrushObject`<br>`glyphstyle` — `TGlyph; TTintedGlyph / TTintedStyleObject (ITintedObject)`<br>`icon` — `TControl (ITintedObject)`<br>`SecondBackground` — `TRectangle`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TCornerButton` — Публикует настройки углов TCustomCornerButton.<br>[FMX.StdCtrls.pas:701](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:701>) | `TCustomCornerButton` | `background` — `TTintedStyleObject / TTintedButtonStyleObject (ITintedObject); TRectangle`<br>`foreground` — `TBrushObject`<br>`glyphstyle` — `TGlyph; TTintedGlyph / TTintedStyleObject (ITintedObject)`<br>`icon` — `TControl (ITintedObject)`<br>`SecondBackground` — `TRectangle`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TCheckBox` — Флажок, отражающий IsChecked через состояние/триггеры стиля.<br>[FMX.StdCtrls.pas:796](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:796>) | `TPresentedTextControl` | `foreground` — `TBrushObject`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TRadioButton` — Переключатель одного варианта в группе.<br>[FMX.StdCtrls.pas:919](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:919>) | `TPresentedTextControl` | `foreground` — `TBrushObject`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TGroupBox` — Контейнер с текстовым заголовком.<br>[FMX.StdCtrls.pas:1040](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:1040>) | `TPresentedTextControl` | `foreground` — `TBrushObject`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TExpanderButton` — Кнопка раскрытия секции.<br>[FMX.StdCtrls.pas:2449](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:2449>) | `TCustomButton` | `background` — `TTintedStyleObject / TTintedButtonStyleObject (ITintedObject)`<br>`foreground` — `TBrushObject`<br>`glyphstyle` — `TGlyph; TTintedGlyph / TTintedStyleObject (ITintedObject)`<br>`icon` — `TControl (ITintedObject)`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TExpander` — Раскрываемый контейнер с заголовком, флажком и кнопкой.<br>[FMX.StdCtrls.pas:2534](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:2534>) | `TTextControl` | `button` — `TCustomButton`<br>`checkbox` — `TCheckBox`<br>`foreground` — `TBrushObject`<br>`header` — `TControl`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TImageControl` — Контрол изображения с именованным TImage.<br>[FMX.StdCtrls.pas:2692](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:2692>) | `TStyledControl` | `image` — `TImage` |
| `TPathLabel` — Подпись вдоль пути, использующая параметры TText.<br>[FMX.StdCtrls.pas:2795](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:2795>) | `TStyledControl` | `text` — `TText` |
| `TSizeGrip` — Самостоятельная ручка изменения размера окна.<br>[FMX.StdCtrls.pas:1294](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:1294>) | `TStyledControl` | Фиксированные имена частей не найдены; см. примечания о корне/представлении. |
| `TSplitter` — Разделитель, изменяющий размер соседних контролов.<br>[FMX.StdCtrls.pas:1366](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:1366>) | `TStyledControl` | `grip` — `TControl`<br>`hgrip` — `TControl` |

**TCheckBox**. Не ищет checkmark/background по именам самостоятельно. Наследует text/foreground; графическое состояние задаётся ресурсом и триггерами IsChecked. Запросы checkmark/background при растеризации ячейки выполняет TCheckColumn, а не обычный TCheckBox.

**TRadioButton**. Собственных фиксированных поисков частей нет; текстовый контракт унаследован, состояние выбора отражается триггерами.


### Текстовый, числовой и календарный ввод

| Класс и назначение | Непосредственный предок / представление | Элементы и классы с учётом наследования |
| --- | --- | --- |
| `TCustomEdit` — База однострочного текстового редактора.<br>[FMX.Edit.pas:241](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.pas:241>) | `TPresentedControl`<br>presentation: `TStyledEdit` | `buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TEdit` — Однострочный редактор с кареткой, выделением и подсказкой.<br>[FMX.Edit.pas:650](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.pas:650>) | `TCustomEdit`<br>presentation: `TStyledEdit` | `buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TClearingEdit` — Совместимый редактор с кнопкой очистки.<br>[FMX.Edit.pas:747](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.pas:747>) | `TEdit`<br>presentation: `TStyledEdit` | `buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TCustomEditBox` — База редакторов числового значения.<br>[FMX.EditBox.pas:70](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.EditBox.pas:70>) | `TCustomEdit`<br>presentation: `TStyledEditBox` | `buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TNumberBox` — Числовой редактор с изменением значения мышью.<br>[FMX.NumberBox.pas:40](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.NumberBox.pas:40>) | `TCustomEditBox`<br>presentation: `TStyledNumberBox` | `buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TSpinBox` — Числовой редактор с кнопками уменьшения/увеличения.<br>[FMX.SpinBox.pas:43](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.SpinBox.pas:43>) | `TCustomEditBox`<br>presentation: `TStyledSpinBox` | `buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`minusbutton` — `TCustomButton`<br>`plusbutton` — `TCustomButton`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TComboEditBase` — База текстового ввода со всплывающим выбором.<br>[FMX.ComboEdit.pas:38](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ComboEdit.pas:38>) | `TCustomEdit`<br>presentation: `TStyledComboEditBase` | `arrow` — `TControl`<br>`buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TCustomComboEdit` — Редактор текста с выбором значения из списка.<br>[FMX.ComboEdit.pas:97](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ComboEdit.pas:97>) | `TComboEditBase`<br>presentation: `TStyledComboEdit` | `arrow` — `TControl`<br>`buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`Content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TComboEdit` — Публикует свойства редактора со списком.<br>[FMX.ComboEdit.pas:148](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ComboEdit.pas:148>) | `TCustomComboEdit`<br>presentation: `TStyledComboEdit` | `arrow` — `TControl`<br>`buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`Content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TComboTrackBar` — Числовой редактор со всплывающим ползунком.<br>[FMX.ComboTrackBar.pas:52](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ComboTrackBar.pas:52>) | `TCustomEditBox`<br>presentation: `TStyledComboTrackBar` | `arrow` — `TControl`<br>`buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TSearchBox` — Строка поиска с очисткой и значком лупы.<br>[FMX.SearchBox.pas:39](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.SearchBox.pas:39>) | `TEdit`<br>presentation: `TStyledSearchBox` | `buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`clearbutton` — `TEditButton`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`magglass` — `TEditButton`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TCustomMaskEdit` — База текстового ввода по маске.<br>[FMX.MaskEdit.pas:90](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.MaskEdit.pas:90>) | `TCustomEdit`<br>presentation: `TStyledMaskEdit` | `buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TMaskEdit` — Редактор с маской допустимых символов.<br>[FMX.MaskEdit.pas:110](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.MaskEdit.pas:110>) | `TCustomMaskEdit`<br>presentation: `TStyledMaskEdit` | `buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TCustomMemo` — База многострочного текстового редактора.<br>[FMX.Memo.pas:234](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Memo.pas:234>) | `TCustomPresentedScrollBox`<br>presentation: `TStyledMemo` | `background` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TMemo` — Многострочный редактор с выделением и прокруткой.<br>[FMX.Memo.pas:443](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Memo.pas:443>) | `TCustomMemo`<br>presentation: `TStyledMemo` | `background` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TCustomCalendar` — База календаря с отдельным presentation.<br>[FMX.Calendar.pas:67](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Calendar.pas:67>) | `TPresentedControl`<br>presentation: `TStyledCalendar` | `days` — `TListBox`<br>`months` — `TPopupBox`<br>`next` — `TButton`<br>`prev` — `TButton`<br>`today` — `TButton`<br>`week` — `TGridLayout`<br>`weeks` — `TGridLayout`<br>`years` — `TPopupBox` |
| `TCalendar` — Календарь выбора месяца, года и дня.<br>[FMX.Calendar.pas:116](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Calendar.pas:116>) | `TCustomCalendar`<br>presentation: `TStyledCalendar` | `days` — `TListBox`<br>`months` — `TPopupBox`<br>`next` — `TButton`<br>`prev` — `TButton`<br>`today` — `TButton`<br>`week` — `TGridLayout`<br>`weeks` — `TGridLayout`<br>`years` — `TPopupBox` |
| `TDayItem` — Внутренняя строка дня календаря на базе TListBoxItem.<br>[FMX.Calendar.Style.pas:136](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Calendar.Style.pas:136>) | `TListBoxItem` | `accessorycheckmark` — `TControl`<br>`accessorydetail` — `TControl`<br>`accessorymore` — `TControl`<br>`background_roundall` — `TControl`<br>`background_roundbottom` — `TControl`<br>`background_roundtop` — `TControl`<br>`background_separatorbottom` — `TControl`<br>`background_sharp` — `TControl`<br>`check` — `TCheckBox`<br>`detail` — `TText / TLabel`<br>`foreground` — `TBrushObject`<br>`glyphstyle` — `TGlyph`<br>`icon` — `TImage`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TCustomCalendarEdit` — База ввода даты со всплывающим календарём.<br>[FMX.CalendarEdit.pas:59](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.CalendarEdit.pas:59>) | `TComboEditBase`<br>presentation: `TStyledCalendarEdit` | `arrow` — `TControl`<br>`buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`Content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TCalendarEdit` — Редактор даты на базе ComboEdit со всплывающим календарём.<br>[FMX.CalendarEdit.pas:99](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.CalendarEdit.pas:99>) | `TCustomCalendarEdit`<br>presentation: `TStyledCalendarEdit` | `arrow` — `TControl`<br>`buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`Content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TCustomDateTimeEdit` — База составного редактора даты/времени с очисткой и флажком.<br>[FMX.DateTimeCtrls.pas:26](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.DateTimeCtrls.pas:26>) | `TTextControl` | `check` — `TCheckBox`<br>`clearbutton` — `TControl`<br>`foreground` — `TBrushObject`<br>`selection` — `TBrushObject`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TCustomDateEdit` — База редактора даты из FMX.DateTimeCtrls.<br>[FMX.DateTimeCtrls.pas:317](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.DateTimeCtrls.pas:317>) | `TCustomDateTimeEdit` | `arrow` — `TControl`<br>`check` — `TCheckBox`<br>`clearbutton` — `TControl`<br>`foreground` — `TBrushObject`<br>`selection` — `TBrushObject`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TDateEdit` — Редактор даты из FMX.DateTimeCtrls; другая ветка, чем TCalendarEdit.<br>[FMX.DateTimeCtrls.pas:347](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.DateTimeCtrls.pas:347>) | `TCustomDateEdit` | `arrow` — `TControl`<br>`check` — `TCheckBox`<br>`clearbutton` — `TControl`<br>`foreground` — `TBrushObject`<br>`selection` — `TBrushObject`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TCustomTimeEdit` — База редактора времени с кнопками вверх/вниз.<br>[FMX.DateTimeCtrls.pas:196](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.DateTimeCtrls.pas:196>) | `TCustomDateTimeEdit` | `check` — `TCheckBox`<br>`clearbutton` — `TControl`<br>`downbutton` — `TControl`<br>`foreground` — `TBrushObject`<br>`selection` — `TBrushObject`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)`<br>`upbutton` — `TControl` |
| `TTimeEdit` — Редактор времени.<br>[FMX.DateTimeCtrls.pas:232](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.DateTimeCtrls.pas:232>) | `TCustomTimeEdit` | `check` — `TCheckBox`<br>`clearbutton` — `TControl`<br>`downbutton` — `TControl`<br>`foreground` — `TBrushObject`<br>`selection` — `TBrushObject`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)`<br>`upbutton` — `TControl` |
| `TEditButton` — Кнопка, встраиваемая в редактор.<br>[FMX.Edit.pas:435](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.pas:435>) | `TCustomButton` | `background` — `TTintedStyleObject / TTintedButtonStyleObject (ITintedObject)`<br>`foreground` — `TBrushObject`<br>`glyphstyle` — `TGlyph; TTintedGlyph / TTintedStyleObject (ITintedObject)`<br>`icon` — `TControl (ITintedObject)`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TClearEditButton` — Кнопка очистки редактора.<br>[FMX.Edit.pas:520](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.pas:520>) | `TEditButton` | `background` — `TTintedStyleObject / TTintedButtonStyleObject (ITintedObject)`<br>`foreground` — `TBrushObject`<br>`glyphstyle` — `TGlyph; TTintedGlyph / TTintedStyleObject (ITintedObject)`<br>`icon` — `TControl (ITintedObject)`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TPasswordEditButton` — Кнопка показа/скрытия парольного текста.<br>[FMX.Edit.pas:528](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.pas:528>) | `TEditButton` | `background` — `TTintedStyleObject / TTintedButtonStyleObject (ITintedObject)`<br>`foreground` — `TBrushObject`<br>`glyphstyle` — `TGlyph; TTintedGlyph / TTintedStyleObject (ITintedObject)`<br>`icon` — `TControl (ITintedObject)`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TSearchEditButton` — Кнопка поиска редактора.<br>[FMX.Edit.pas:538](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.pas:538>) | `TEditButton` | `background` — `TTintedStyleObject / TTintedButtonStyleObject (ITintedObject)`<br>`foreground` — `TBrushObject`<br>`glyphstyle` — `TGlyph; TTintedGlyph / TTintedStyleObject (ITintedObject)`<br>`icon` — `TControl (ITintedObject)`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TEllipsesEditButton` — Кнопка дополнительного действия с многоточием.<br>[FMX.Edit.pas:545](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.pas:545>) | `TEditButton` | `background` — `TTintedStyleObject / TTintedButtonStyleObject (ITintedObject)`<br>`foreground` — `TBrushObject`<br>`glyphstyle` — `TGlyph; TTintedGlyph / TTintedStyleObject (ITintedObject)`<br>`icon` — `TControl (ITintedObject)`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TDropDownEditButton` — Кнопка раскрытия выбора в редакторе.<br>[FMX.Edit.pas:552](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.pas:552>) | `TEditButton` | `background` — `TTintedStyleObject / TTintedButtonStyleObject (ITintedObject)`<br>`foreground` — `TBrushObject`<br>`glyphstyle` — `TGlyph; TTintedGlyph / TTintedStyleObject (ITintedObject)`<br>`icon` — `TControl (ITintedObject)`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TSpinEditButton` — Составная кнопка редактора с upbutton/downbutton.<br>[FMX.Edit.pas:559](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.pas:559>) | `TStyledControl` | `downbutton` — `TCustomButton`<br>`upbutton` — `TCustomButton` |


### Диапазоны, индикаторы и выделение

| Класс и назначение | Непосредственный предок / представление | Элементы и классы с учётом наследования |
| --- | --- | --- |
| `TProgressBar` — Индикатор прогресса с выбором ориентации.<br>[FMX.StdCtrls.pas:1467](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:1467>) | `TPresentedControl` | `hindicator` — `TControl; TLayout / TStyleObject`<br>`htrack` — `TControl`<br>`track` — `TControl`<br>`vindicator` — `TControl; TLayout / TStyleObject`<br>`vtrack` — `TControl` |
| `TThumb` — Перетаскиваемый бегунок трека.<br>[FMX.StdCtrls.pas:1576](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:1576>) | `TStyledControl` | Фиксированные имена частей не найдены; см. примечания о корне/представлении. |
| `TCustomTrack` — База трека диапазона с бегунком и подсветкой.<br>[FMX.StdCtrls.pas:1662](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:1662>) | `TPresentedControl` | `hthumb` — `TThumb`<br>`htrack` — `TControl`<br>`thumb` — `TThumb`<br>`thumbsize` — `TStyleTag`<br>`track` — `TControl`<br>`vthumb` — `TThumb`<br>`vtrack` — `TControl`<br>`внутри track/htrack/vtrack → highlight` — `TControl` |
| `TTrack` — Трек с опубликованными свойствами диапазона.<br>[FMX.StdCtrls.pas:1774](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:1774>) | `TCustomTrack` | `hthumb` — `TThumb`<br>`htrack` — `TControl`<br>`thumb` — `TThumb`<br>`thumbsize` — `TStyleTag`<br>`track` — `TControl`<br>`vthumb` — `TThumb`<br>`vtrack` — `TControl`<br>`внутри track/htrack/vtrack → highlight` — `TControl` |
| `TTrackBar` — Ползунок выбора числового значения.<br>[FMX.StdCtrls.pas:1853](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:1853>) | `TCustomTrack` | `hthumb` — `TThumb`<br>`htrack` — `TControl`<br>`thumb` — `TThumb`<br>`thumbsize` — `TStyleTag`<br>`track` — `TControl`<br>`vthumb` — `TThumb`<br>`vtrack` — `TControl`<br>`внутри track/htrack/vtrack → highlight` — `TControl` |
| `TBitmapTrackBar` — Ползунок с растровым изображением фона трека.<br>[FMX.StdCtrls.pas:1938](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:1938>) | `TTrackBar` | `hthumb` — `TThumb`<br>`htrack` — `TControl`<br>`thumb` — `TThumb`<br>`thumbsize` — `TStyleTag`<br>`track` — `TControl`<br>`vthumb` — `TThumb`<br>`vtrack` — `TControl`<br>`внутри htrack/vtrack → background` — `TRectangle`<br>`внутри track/htrack/vtrack → highlight` — `TControl` |
| `TCustomSwitch` — База двухпозиционного переключателя.<br>[FMX.StdCtrls.pas:1985](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:1985>) | `TPresentedControl`<br>presentation: `TStyledSwitch` | Фиксированные имена частей не найдены; см. примечания о корне/представлении. |
| `TSwitch` — Переключатель, использующий TCustomSwitchObject как корень стиля.<br>[FMX.StdCtrls.pas:2025](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:2025>) | `TCustomSwitch`<br>presentation: `TStyledSwitch` | Фиксированные имена частей не найдены; см. примечания о корне/представлении. |
| `TScrollBar` — Полоса прокрутки с треком и кнопками направлений.<br>[FMX.StdCtrls.pas:2090](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:2090>) | `TStyledControl` | `bottombutton` — `TCustomButton`<br>`htrack` — `TCustomTrack`<br>`leftbutton` — `TCustomButton`<br>`rightbutton` — `TCustomButton`<br>`topbutton` — `TCustomButton`<br>`track` — `TCustomTrack`<br>`vtrack` — `TCustomTrack` |
| `TSmallScrollBar` — Компактная полоса прокрутки.<br>[FMX.StdCtrls.pas:2226](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:2226>) | `TScrollBar` | `bottombutton` — `TCustomButton`<br>`htrack` — `TCustomTrack`<br>`leftbutton` — `TCustomButton`<br>`rightbutton` — `TCustomButton`<br>`topbutton` — `TCustomButton`<br>`track` — `TCustomTrack`<br>`vtrack` — `TCustomTrack` |
| `TAniIndicator` — Анимированный индикатор ожидания.<br>[FMX.StdCtrls.pas:2238](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:2238>) | `TStyledControl` | `ani` — `TAnimation`<br>`fill` — `TBrushObject (IBrushObject)`<br>`text` — `TText` |
| `TArcDial` — Круговой регулятор угла с указателем и подписями.<br>[FMX.StdCtrls.pas:2327](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:2327>) | `TPresentedControl` | `text` — `TText`<br>`tick` — `TControl (IRotatedControl)`<br>`tracktext` — `TText` |
| `TSelectionPoint` — Маркер текстового выделения/каретки.<br>[FMX.Objects.pas:1005](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Objects.pas:1005>) | `TStyledControl` | `Background` — `TControl` |
| `TCustomMagnifierGlass` — База экранной лупы.<br>[FMX.MagnifierGlass.pas:32](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.MagnifierGlass.pas:32>) | `TPresentedControl` | `content` — `TShape` |
| `TMagnifierGlass` — Экранная лупа.<br>[FMX.MagnifierGlass.pas:82](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.MagnifierGlass.pas:82>) | `TCustomMagnifierGlass` | `content` — `TShape` |

**TCustomSwitch**. TStyledSwitch проверяет корневой ResourceLink на TCustomSwitchObject. Фиксированного поиска track/thumb в его ApplyStyle нет.


### Прокручиваемые контейнеры

| Класс и назначение | Непосредственный предок / представление | Элементы и классы с учётом наследования |
| --- | --- | --- |
| `TCustomScrollBox` — Styled контейнер прокрутки из FMX.Layouts без отдельного presentation.<br>[FMX.Layouts.pas:194](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Layouts.pas:194>) | `TStyledControl` | `background` — `TControl`<br>`content` — `TControl`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TScrollBox` — Прокрутка по обеим осям.<br>[FMX.Layouts.pas:434](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Layouts.pas:434>) | `TCustomScrollBox` | `background` — `TControl`<br>`content` — `TControl`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TVertScrollBox` — Вертикальный контейнер прокрутки.<br>[FMX.Layouts.pas:508](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Layouts.pas:508>) | `TCustomScrollBox` | `background` — `TControl`<br>`content` — `TControl`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `THorzScrollBox` — Горизонтальный контейнер прокрутки.<br>[FMX.Layouts.pas:584](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Layouts.pas:584>) | `TCustomScrollBox` | `background` — `TControl`<br>`content` — `TControl`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TFramedScrollBox` — Контейнер прокрутки с рамкой.<br>[FMX.Layouts.pas:660](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Layouts.pas:660>) | `TCustomScrollBox` | `background` — `TControl`<br>`content` — `TControl`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TFramedVertScrollBox` — Вертикальный контейнер с рамкой.<br>[FMX.Layouts.pas:737](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Layouts.pas:737>) | `TVertScrollBox` | `background` — `TControl`<br>`content` — `TControl`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TCustomPresentedScrollBox` — База контейнера прокрутки с отдельным presentation.<br>[FMX.ScrollBox.pas:271](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ScrollBox.pas:271>) | `TPresentedControl`<br>presentation: `TStyledCustomScrollBox` | `background` — `TControl`<br>`content` — `TControl`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TPresentedScrollBox` — Presentation-контейнер прокрутки по обеим осям.<br>[FMX.ScrollBox.pas:447](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ScrollBox.pas:447>) | `TCustomPresentedScrollBox`<br>presentation: `TStyledCustomScrollBox` | `background` — `TControl`<br>`content` — `TControl`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TCustomPresentedVertScrollBox` — База вертикального presentation-контейнера.<br>[FMX.ScrollBox.pas:521](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ScrollBox.pas:521>) | `TCustomPresentedScrollBox`<br>presentation: `TStyledCustomScrollBox` | `background` — `TControl`<br>`content` — `TControl`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TPresentedVertScrollBox` — Вертикальный presentation-контейнер.<br>[FMX.ScrollBox.pas:529](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ScrollBox.pas:529>) | `TCustomPresentedVertScrollBox`<br>presentation: `TStyledCustomScrollBox` | `background` — `TControl`<br>`content` — `TControl`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TCustomPresentedHorzScrollBox` — База горизонтального presentation-контейнера.<br>[FMX.ScrollBox.pas:601](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ScrollBox.pas:601>) | `TCustomPresentedScrollBox`<br>presentation: `TStyledCustomScrollBox` | `background` — `TControl`<br>`content` — `TControl`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TPresentedHorzScrollBox` — Горизонтальный presentation-контейнер.<br>[FMX.ScrollBox.pas:609](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ScrollBox.pas:609>) | `TCustomPresentedHorzScrollBox`<br>presentation: `TStyledCustomScrollBox` | `background` — `TControl`<br>`content` — `TControl`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TCustomPresentedFramedScrollBox` — База presentation-контейнера с рамкой.<br>[FMX.ScrollBox.pas:681](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ScrollBox.pas:681>) | `TCustomPresentedScrollBox`<br>presentation: `TStyledCustomScrollBox` | `background` — `TControl`<br>`content` — `TControl`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TPresentedFramedScrollBox` — Presentation-контейнер с рамкой.<br>[FMX.ScrollBox.pas:687](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ScrollBox.pas:687>) | `TCustomPresentedFramedScrollBox`<br>presentation: `TStyledCustomScrollBox` | `background` — `TControl`<br>`content` — `TControl`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TCustomPresentedFramedVertScrollBox` — База вертикального presentation-контейнера с рамкой.<br>[FMX.ScrollBox.pas:759](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ScrollBox.pas:759>) | `TCustomPresentedVertScrollBox`<br>presentation: `TStyledCustomScrollBox` | `background` — `TControl`<br>`content` — `TControl`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TPresentedFramedVertScrollBox` — Вертикальный presentation-контейнер с рамкой.<br>[FMX.ScrollBox.pas:766](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ScrollBox.pas:766>) | `TCustomPresentedFramedVertScrollBox`<br>presentation: `TStyledCustomScrollBox` | `background` — `TControl`<br>`content` — `TControl`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |


### Списки, деревья и выбор

| Класс и назначение | Непосредственный предок / представление | Элементы и классы с учётом наследования |
| --- | --- | --- |
| `TListBoxItem` — Строка списка с текстом, флажком, изображением и ItemData.<br>[FMX.ListBox.pas:30](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:30>) | `TTextControl` | `accessorycheckmark` — `TControl`<br>`accessorydetail` — `TControl`<br>`accessorymore` — `TControl`<br>`background_roundall` — `TControl`<br>`background_roundbottom` — `TControl`<br>`background_roundtop` — `TControl`<br>`background_separatorbottom` — `TControl`<br>`background_sharp` — `TControl`<br>`check` — `TCheckBox`<br>`detail` — `TText / TLabel`<br>`foreground` — `TBrushObject`<br>`glyphstyle` — `TGlyph`<br>`icon` — `TImage`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TListBoxSeparatorItem` — Разделительный элемент списка.<br>[FMX.ListBox.pas:609](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:609>) | `TListBoxItem` | `accessorycheckmark` — `TControl`<br>`accessorydetail` — `TControl`<br>`accessorymore` — `TControl`<br>`background_roundall` — `TControl`<br>`background_roundbottom` — `TControl`<br>`background_roundtop` — `TControl`<br>`background_separatorbottom` — `TControl`<br>`background_sharp` — `TControl`<br>`check` — `TCheckBox`<br>`detail` — `TText / TLabel`<br>`foreground` — `TBrushObject`<br>`glyphstyle` — `TGlyph`<br>`icon` — `TImage`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TListBoxGroupHeader` — Заголовок группы элементов списка.<br>[FMX.ListBox.pas:616](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:616>) | `TListBoxSeparatorItem` | `accessorycheckmark` — `TControl`<br>`accessorydetail` — `TControl`<br>`accessorymore` — `TControl`<br>`background_roundall` — `TControl`<br>`background_roundbottom` — `TControl`<br>`background_roundtop` — `TControl`<br>`background_separatorbottom` — `TControl`<br>`background_sharp` — `TControl`<br>`check` — `TCheckBox`<br>`detail` — `TText / TLabel`<br>`foreground` — `TBrushObject`<br>`glyphstyle` — `TGlyph`<br>`icon` — `TImage`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TListBoxGroupFooter` — Нижний элемент группы списка.<br>[FMX.ListBox.pas:629](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:629>) | `TListBoxSeparatorItem` | `accessorycheckmark` — `TControl`<br>`accessorydetail` — `TControl`<br>`accessorymore` — `TControl`<br>`background_roundall` — `TControl`<br>`background_roundbottom` — `TControl`<br>`background_roundtop` — `TControl`<br>`background_separatorbottom` — `TControl`<br>`background_sharp` — `TControl`<br>`check` — `TCheckBox`<br>`detail` — `TText / TLabel`<br>`foreground` — `TBrushObject`<br>`glyphstyle` — `TGlyph`<br>`icon` — `TImage`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TMetropolisUIListBoxItem` — Строка списка с оформлением Metropolis UI.<br>[FMX.ListBox.pas:967](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:967>) | `TListBoxItem` | `accessorycheckmark` — `TControl`<br>`accessorydetail` — `TControl`<br>`accessorymore` — `TControl`<br>`background_roundall` — `TControl`<br>`background_roundbottom` — `TControl`<br>`background_roundtop` — `TControl`<br>`background_separatorbottom` — `TControl`<br>`background_sharp` — `TControl`<br>`check` — `TCheckBox`<br>`detail` — `TText / TLabel`<br>`foreground` — `TBrushObject`<br>`glyphstyle` — `TGlyph`<br>`icon` — `TImage`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TCustomListBox` — База списка с прокруткой, выделением и чередованием фона.<br>[FMX.ListBox.pas:244](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:244>) | `TScrollBox` | `AlternatingRowBackground` — `TBrushObject (IBrushObject)`<br>`background` — `TControl`<br>`content` — `TControl`<br>`extendedselection` — `TControl`<br>`focusedselection` — `TControl`<br>`footer` — `TControl`<br>`header` — `TControl`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`selection` — `TControl`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TListBox` — Список контролов TListBoxItem.<br>[FMX.ListBox.pas:519](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:519>) | `TCustomListBox` | `AlternatingRowBackground` — `TBrushObject (IBrushObject)`<br>`background` — `TControl`<br>`content` — `TControl`<br>`extendedselection` — `TControl`<br>`focusedselection` — `TControl`<br>`footer` — `TControl`<br>`header` — `TControl`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`selection` — `TControl`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TListBoxHeader` — Заголовок списка на базе TToolBar.<br>[FMX.ListBox.pas:603](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:603>) | `TToolBar` | Фиксированные имена частей не найдены; см. примечания о корне/представлении. |
| `TComboListBox` — Вспомогательный список выбора ComboBox.<br>[FMX.ListBox.pas:745](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:745>) | `TCustomListBox` | `AlternatingRowBackground` — `TBrushObject (IBrushObject)`<br>`background` — `TControl`<br>`content` — `TControl`<br>`extendedselection` — `TControl`<br>`focusedselection` — `TControl`<br>`footer` — `TControl`<br>`header` — `TControl`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`selection` — `TControl`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TCustomComboBox` — База выпадающего выбора с областью текущего элемента.<br>[FMX.ListBox.pas:762](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:762>) | `TStyledControl` | `Content` — `TControl` |
| `TComboBox` — Выпадающий список.<br>[FMX.ListBox.pas:882](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:882>) | `TCustomComboBox` | `Content` — `TControl` |
| `TComboEditListBox` — Вспомогательный список styled представления ComboEdit.<br>[FMX.ComboEdit.Style.pas:26](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ComboEdit.Style.pas:26>) | `TCustomListBox` | `AlternatingRowBackground` — `TBrushObject (IBrushObject)`<br>`background` — `TControl`<br>`content` — `TControl`<br>`extendedselection` — `TControl`<br>`focusedselection` — `TControl`<br>`footer` — `TControl`<br>`header` — `TControl`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`selection` — `TControl`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TTreeViewItem` — Узел дерева с текстом, раскрытием, флажком и глифом.<br>[FMX.TreeView.pas:26](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.TreeView.pas:26>) | `TTextControl` | `button` — `TCustomButton`<br>`check` — `TCheckBox`<br>`expander` — `TControl`<br>`foreground` — `TBrushObject`<br>`glyphstyle` — `TGlyph`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TCustomTreeView` — База дерева с прокруткой и выделением.<br>[FMX.TreeView.pas:215](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.TreeView.pas:215>) | `TScrollBox` | `AlternatingRowBackground` — `TBrushObject (IBrushObject)`<br>`background` — `TControl`<br>`content` — `TControl`<br>`focusedselection` — `TControl`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`selection` — `TControl`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TTreeView` — Дерево контролов TTreeViewItem.<br>[FMX.TreeView.pas:371](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.TreeView.pas:371>) | `TCustomTreeView` | `AlternatingRowBackground` — `TBrushObject (IBrushObject)`<br>`background` — `TControl`<br>`content` — `TControl`<br>`focusedselection` — `TControl`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`selection` — `TControl`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TAdapterListView` — База ListView, связывающая отображение с адаптером данных.<br>[FMX.ListView.pas:31](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:31>) | `TStyledControl` | Фиксированные имена частей не найдены; см. примечания о корне/представлении. |
| `TListViewBase` — ListView, загружающий цвета, шрифты и изображения оформления строк.<br>[FMX.ListView.pas:84](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:84>) | `TAdapterListView` | `accessorycheckmark` — `TStyleObject`<br>`accessorycheckmarkselected` — `TStyleObject`<br>`accessorydetail` — `TStyleObject`<br>`accessorydetailselected` — `TStyleObject`<br>`accessorymore` — `TStyleObject`<br>`accessorymoreselected` — `TStyleObject`<br>`additembutton` — `TStyleObject`<br>`additembuttonpressed` — `TStyleObject`<br>`alternatingitembackground` — `TColorObject / TText`<br>`background` — `TColorObject / TText`<br>`button` — `TStyleObject`<br>`buttonfont` — `TFontObject / TText`<br>`buttonpressed` — `TStyleObject`<br>`buttontext` — `TColorObject / TText`<br>`buttontextpressed` — `TColorObject / TText`<br>`checkboxchecked` — `TStyleObject`<br>`checkboxunchecked` — `TStyleObject`<br>`deletebutton` — `TStyleObject`<br>`deletebuttonfont` — `TFontObject / TText`<br>`deletebuttonpressed` — `TStyleObject`<br>`deletebuttontext` — `TColorObject / TText`<br>`deletebuttontextpressed` — `TColorObject / TText`<br>`deleteitembutton` — `TStyleObject`<br>`deleteitembuttonglyph` — `TStyleObject`<br>`detailfont` — `TFontObject / TText`<br>`detailtext` — `TColorObject / TText`<br>`font` — `TFontObject / TText`<br>`foreground` — `TColorObject / TText`<br>`frame` — `TColorObject / TText`<br>`glow` — `TColorObject / TText`<br>`header` — `TStyleObject`<br>`headerfont` — `TFontObject / TText`<br>`headertext` — `TColorObject / TText`<br>`headertextshadow` — `TColorObject / TText`<br>`indicator` — `TColorObject / TText`<br>`itembackground` — `TColorObject / TText`<br>`pullrefreshstroke` — `TColorObject / TText`<br>`selection` — `TColorObject / TText; TStyleObject`<br>`selectiontext` — `TColorObject / TText`<br>`touchanimation` — `TCustomStyleObject (ITouchAnimationObject)` |
| `TPresentedListView` — ListView с выбором styled/native отображения.<br>[FMX.ListView.pas:665](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:665>) | `TListViewBase` | `accessorycheckmark` — `TStyleObject`<br>`accessorycheckmarkselected` — `TStyleObject`<br>`accessorydetail` — `TStyleObject`<br>`accessorydetailselected` — `TStyleObject`<br>`accessorymore` — `TStyleObject`<br>`accessorymoreselected` — `TStyleObject`<br>`additembutton` — `TStyleObject`<br>`additembuttonpressed` — `TStyleObject`<br>`alternatingitembackground` — `TColorObject / TText`<br>`background` — `TColorObject / TText`<br>`button` — `TStyleObject`<br>`buttonfont` — `TFontObject / TText`<br>`buttonpressed` — `TStyleObject`<br>`buttontext` — `TColorObject / TText`<br>`buttontextpressed` — `TColorObject / TText`<br>`checkboxchecked` — `TStyleObject`<br>`checkboxunchecked` — `TStyleObject`<br>`deletebutton` — `TStyleObject`<br>`deletebuttonfont` — `TFontObject / TText`<br>`deletebuttonpressed` — `TStyleObject`<br>`deletebuttontext` — `TColorObject / TText`<br>`deletebuttontextpressed` — `TColorObject / TText`<br>`deleteitembutton` — `TStyleObject`<br>`deleteitembuttonglyph` — `TStyleObject`<br>`detailfont` — `TFontObject / TText`<br>`detailtext` — `TColorObject / TText`<br>`font` — `TFontObject / TText`<br>`foreground` — `TColorObject / TText`<br>`frame` — `TColorObject / TText`<br>`glow` — `TColorObject / TText`<br>`header` — `TStyleObject`<br>`headerfont` — `TFontObject / TText`<br>`headertext` — `TColorObject / TText`<br>`headertextshadow` — `TColorObject / TText`<br>`indicator` — `TColorObject / TText`<br>`itembackground` — `TColorObject / TText`<br>`pullrefreshstroke` — `TColorObject / TText`<br>`selection` — `TColorObject / TText; TStyleObject`<br>`selectiontext` — `TColorObject / TText`<br>`touchanimation` — `TCustomStyleObject (ITouchAnimationObject)` |
| `TAppearanceListView` — ListView с шаблонами Appearance объектов строки.<br>[FMX.ListView.pas:741](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:741>) | `TPresentedListView` | `accessorycheckmark` — `TStyleObject`<br>`accessorycheckmarkselected` — `TStyleObject`<br>`accessorydetail` — `TStyleObject`<br>`accessorydetailselected` — `TStyleObject`<br>`accessorymore` — `TStyleObject`<br>`accessorymoreselected` — `TStyleObject`<br>`additembutton` — `TStyleObject`<br>`additembuttonpressed` — `TStyleObject`<br>`alternatingitembackground` — `TColorObject / TText`<br>`background` — `TColorObject / TText`<br>`button` — `TStyleObject`<br>`buttonfont` — `TFontObject / TText`<br>`buttonpressed` — `TStyleObject`<br>`buttontext` — `TColorObject / TText`<br>`buttontextpressed` — `TColorObject / TText`<br>`checkboxchecked` — `TStyleObject`<br>`checkboxunchecked` — `TStyleObject`<br>`deletebutton` — `TStyleObject`<br>`deletebuttonfont` — `TFontObject / TText`<br>`deletebuttonpressed` — `TStyleObject`<br>`deletebuttontext` — `TColorObject / TText`<br>`deletebuttontextpressed` — `TColorObject / TText`<br>`deleteitembutton` — `TStyleObject`<br>`deleteitembuttonglyph` — `TStyleObject`<br>`detailfont` — `TFontObject / TText`<br>`detailtext` — `TColorObject / TText`<br>`font` — `TFontObject / TText`<br>`foreground` — `TColorObject / TText`<br>`frame` — `TColorObject / TText`<br>`glow` — `TColorObject / TText`<br>`header` — `TStyleObject`<br>`headerfont` — `TFontObject / TText`<br>`headertext` — `TColorObject / TText`<br>`headertextshadow` — `TColorObject / TText`<br>`indicator` — `TColorObject / TText`<br>`itembackground` — `TColorObject / TText`<br>`pullrefreshstroke` — `TColorObject / TText`<br>`selection` — `TColorObject / TText; TStyleObject`<br>`selectiontext` — `TColorObject / TText`<br>`touchanimation` — `TCustomStyleObject (ITouchAnimationObject)` |
| `TCustomListView` — База пользовательского списка Appearance.<br>[FMX.ListView.pas:958](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:958>) | `TAppearanceListView` | `accessorycheckmark` — `TStyleObject`<br>`accessorycheckmarkselected` — `TStyleObject`<br>`accessorydetail` — `TStyleObject`<br>`accessorydetailselected` — `TStyleObject`<br>`accessorymore` — `TStyleObject`<br>`accessorymoreselected` — `TStyleObject`<br>`additembutton` — `TStyleObject`<br>`additembuttonpressed` — `TStyleObject`<br>`alternatingitembackground` — `TColorObject / TText`<br>`background` — `TColorObject / TText`<br>`button` — `TStyleObject`<br>`buttonfont` — `TFontObject / TText`<br>`buttonpressed` — `TStyleObject`<br>`buttontext` — `TColorObject / TText`<br>`buttontextpressed` — `TColorObject / TText`<br>`checkboxchecked` — `TStyleObject`<br>`checkboxunchecked` — `TStyleObject`<br>`deletebutton` — `TStyleObject`<br>`deletebuttonfont` — `TFontObject / TText`<br>`deletebuttonpressed` — `TStyleObject`<br>`deletebuttontext` — `TColorObject / TText`<br>`deletebuttontextpressed` — `TColorObject / TText`<br>`deleteitembutton` — `TStyleObject`<br>`deleteitembuttonglyph` — `TStyleObject`<br>`detailfont` — `TFontObject / TText`<br>`detailtext` — `TColorObject / TText`<br>`font` — `TFontObject / TText`<br>`foreground` — `TColorObject / TText`<br>`frame` — `TColorObject / TText`<br>`glow` — `TColorObject / TText`<br>`header` — `TStyleObject`<br>`headerfont` — `TFontObject / TText`<br>`headertext` — `TColorObject / TText`<br>`headertextshadow` — `TColorObject / TText`<br>`indicator` — `TColorObject / TText`<br>`itembackground` — `TColorObject / TText`<br>`pullrefreshstroke` — `TColorObject / TText`<br>`selection` — `TColorObject / TText; TStyleObject`<br>`selectiontext` — `TColorObject / TText`<br>`touchanimation` — `TCustomStyleObject (ITouchAnimationObject)` |
| `TListView` — Список с Appearance; drawables строки не являются обычными дочерними контролами.<br>[FMX.ListView.pas:961](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:961>) | `TCustomListView` | `accessorycheckmark` — `TStyleObject`<br>`accessorycheckmarkselected` — `TStyleObject`<br>`accessorydetail` — `TStyleObject`<br>`accessorydetailselected` — `TStyleObject`<br>`accessorymore` — `TStyleObject`<br>`accessorymoreselected` — `TStyleObject`<br>`additembutton` — `TStyleObject`<br>`additembuttonpressed` — `TStyleObject`<br>`alternatingitembackground` — `TColorObject / TText`<br>`background` — `TColorObject / TText`<br>`button` — `TStyleObject`<br>`buttonfont` — `TFontObject / TText`<br>`buttonpressed` — `TStyleObject`<br>`buttontext` — `TColorObject / TText`<br>`buttontextpressed` — `TColorObject / TText`<br>`checkboxchecked` — `TStyleObject`<br>`checkboxunchecked` — `TStyleObject`<br>`deletebutton` — `TStyleObject`<br>`deletebuttonfont` — `TFontObject / TText`<br>`deletebuttonpressed` — `TStyleObject`<br>`deletebuttontext` — `TColorObject / TText`<br>`deletebuttontextpressed` — `TColorObject / TText`<br>`deleteitembutton` — `TStyleObject`<br>`deleteitembuttonglyph` — `TStyleObject`<br>`detailfont` — `TFontObject / TText`<br>`detailtext` — `TColorObject / TText`<br>`font` — `TFontObject / TText`<br>`foreground` — `TColorObject / TText`<br>`frame` — `TColorObject / TText`<br>`glow` — `TColorObject / TText`<br>`header` — `TStyleObject`<br>`headerfont` — `TFontObject / TText`<br>`headertext` — `TColorObject / TText`<br>`headertextshadow` — `TColorObject / TText`<br>`indicator` — `TColorObject / TText`<br>`itembackground` — `TColorObject / TText`<br>`pullrefreshstroke` — `TColorObject / TText`<br>`selection` — `TColorObject / TText; TStyleObject`<br>`selectiontext` — `TColorObject / TText`<br>`touchanimation` — `TCustomStyleObject (ITouchAnimationObject)` |


### Вкладки, меню и заголовки

| Класс и назначение | Непосредственный предок / представление | Элементы и классы с учётом наследования |
| --- | --- | --- |
| `TTabItem` — Вкладка с вариантами top/bottom, текстом и изображением.<br>[FMX.TabControl.pas:116](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.TabControl.pas:116>) | `TTextControl` | `bottom` — `TControl`<br>`foreground` — `TBrushObject`<br>`glyphstyle` — `TGlyph`<br>`icon` — `TControl (IMultiResBitmapObject)`<br>`layoutstyle` — `TControl`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)`<br>`top` — `TControl` |
| `TTabControl` — Контейнер вкладок с параметрами высоты и фона перехода.<br>[FMX.TabControl.pas:332](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.TabControl.pas:332>) | `TStyledControl` | `background` — `TControl`<br>`FullSize` — `TStyleTag / TLayout`<br>`scrollbackground` — `TBrushObject`<br>`TabHeight` — `TStyleTag` |
| `TMenuItem` — Пункт меню с текстом, отметкой, глифом, shortcut и указателем подменю.<br>[FMX.Menus.pas:84](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Menus.pas:84>) | `TTextControl` | `bitmap` — `TControl`<br>`checkbackground` — `TControl`<br>`checkmark` — `TControl`<br>`checkmarkstyle` — `TControl`<br>`foreground` — `TBrushObject`<br>`glyph` — `TControl`<br>`glyphstyle` — `TGlyph`<br>`height` — `TStyleTag`<br>`shortcut` — `TText`<br>`submark` — `TControl`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TMenuBar` — Горизонтальная строка меню.<br>[FMX.Menus.pas:335](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Menus.pas:335>) | `TStyledControl` | `content` — `TControl` |
| `TMenuView` — Визуальный контейнер пунктов меню.<br>[FMX.Menus.pas:979](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Menus.pas:979>) | `TStyledControl` | `content` — `TControl` |
| `THeaderItem` — Заголовок колонки на базе угловой кнопки.<br>[FMX.Header.pas:28](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Header.pas:28>) | `TCustomCornerButton` | `background` — `TTintedStyleObject / TTintedButtonStyleObject (ITintedObject); TRectangle`<br>`foreground` — `TBrushObject`<br>`glyphstyle` — `TGlyph; TTintedGlyph / TTintedStyleObject (ITintedObject)`<br>`icon` — `TControl (ITintedObject)`<br>`SecondBackground` — `TRectangle`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `THeader` — Контейнер отдельных заголовков THeaderItem.<br>[FMX.Header.pas:131](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Header.pas:131>) | `TStyledControl` | Фиксированные имена частей не найдены; см. примечания о корне/представлении. |
| `TGridHeaderItem` — Заголовок колонки таблицы.<br>[FMX.Grid.Style.pas:29](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:29>) | `THeaderItem` | `background` — `TTintedStyleObject / TTintedButtonStyleObject (ITintedObject); TRectangle`<br>`foreground` — `TBrushObject`<br>`glyphstyle` — `TGlyph; TTintedGlyph / TTintedStyleObject (ITintedObject)`<br>`icon` — `TControl (ITintedObject)`<br>`SecondBackground` — `TRectangle`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |

**THeader**. Собственных фиксированных поисков частей нет. Заголовки колонок создаются как отдельные THeaderItem со своим стилем.


### Таблицы и внутренние контролы ячеек

| Класс и назначение | Непосредственный предок / представление | Элементы и классы с учётом наследования |
| --- | --- | --- |
| `TCustomGrid` — База таблицы с отдельным styled представлением.<br>[FMX.Grid.pas:1030](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.pas:1030>) | `TCustomPresentedScrollBox`<br>presentation: `TStyledGrid` | `AlternatingRowBackground` — `TBrushObject`<br>`background` — `TControl`<br>`content` — `TControl`<br>`EditorBackground` — `TBrushObject`<br>`EditorLineFill` — `TBrushObject`<br>`focus` — `TControl`<br>`header` — `THeader; TControl`<br>`hscrollbar` — `TScrollBar; TControl`<br>`hsmallscrollbar` — `TScrollBar; TControl`<br>`LineFill` — `TBrushObject`<br>`selection` — `TControl`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar; TControl`<br>`vsmallscrollbar` — `TScrollBar; TControl` |
| `TGrid` — Таблица с типизированными колонками.<br>[FMX.Grid.pas:1291](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.pas:1291>) | `TCustomGrid`<br>presentation: `TStyledGrid` | `AlternatingRowBackground` — `TBrushObject`<br>`background` — `TControl`<br>`content` — `TControl`<br>`EditorBackground` — `TBrushObject`<br>`EditorLineFill` — `TBrushObject`<br>`focus` — `TControl`<br>`header` — `THeader; TControl`<br>`hscrollbar` — `TScrollBar; TControl`<br>`hsmallscrollbar` — `TScrollBar; TControl`<br>`LineFill` — `TBrushObject`<br>`selection` — `TControl`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar; TControl`<br>`vsmallscrollbar` — `TScrollBar; TControl` |
| `TStringGrid` — Таблица строковых значений.<br>[FMX.Grid.pas:1384](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.pas:1384>) | `TCustomGrid`<br>presentation: `TStyledGrid` | `AlternatingRowBackground` — `TBrushObject`<br>`background` — `TControl`<br>`content` — `TControl`<br>`EditorBackground` — `TBrushObject`<br>`EditorLineFill` — `TBrushObject`<br>`focus` — `TControl`<br>`header` — `THeader; TControl`<br>`hscrollbar` — `TScrollBar; TControl`<br>`hsmallscrollbar` — `TScrollBar; TControl`<br>`LineFill` — `TBrushObject`<br>`selection` — `TControl`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar; TControl`<br>`vsmallscrollbar` — `TScrollBar; TControl` |
| `TDefaultEditor` — Внутренний однострочный редактор ячейки.<br>[FMX.Grid.Style.pas:393](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:393>) | `TCustomEdit`<br>presentation: `TStyledEdit` | `buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TNumberCell` — Внутренний числовой редактор на базе TDefaultEditor.<br>[FMX.Grid.Style.pas:494](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:494>) | `TDefaultEditor`<br>presentation: `TStyledEdit` | `buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TCellText` — Внутреннее текстовое оформление ячейки.<br>[FMX.Grid.Style.pas:532](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:532>) | `TTextControl` | `font` — `TFontObject`<br>`foreground` — `TBrushObject`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TProgressCell` — Индикатор прогресса в ячейке.<br>[FMX.Grid.Style.pas:588](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:588>) | `TProgressBar` | `hindicator` — `TStyleObject / TStyleTextObject (IDrawableObject); TControl; TLayout / TStyleObject`<br>`htrack` — `TStyleObject / TStyleTextObject (IDrawableObject); TControl`<br>`track` — `TStyleObject / TStyleTextObject (IDrawableObject); TControl`<br>`vindicator` — `TControl; TLayout / TStyleObject`<br>`vtrack` — `TControl` |
| `TCheckCell` — Флажок редактора логической ячейки.<br>[FMX.Grid.Style.pas:687](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:687>) | `TCheckBox` | `background` — `TControl`<br>`foreground` — `TBrushObject`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TDateCell` — Редактор даты в ячейке.<br>[FMX.Grid.Style.pas:872](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:872>) | `TCustomDateEdit` | `arrow` — `TControl`<br>`background` — `TControl`<br>`check` — `TCheckBox`<br>`clearbutton` — `TControl`<br>`content` — `TControl`<br>`foreground` — `TBrushObject`<br>`selection` — `TBrushObject`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState); TControl` |
| `TTimeCell` — Редактор времени в ячейке.<br>[FMX.Grid.Style.pas:990](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:990>) | `TCustomTimeEdit` | `background` — `TControl`<br>`check` — `TCheckBox`<br>`clearbutton` — `TControl`<br>`content` — `TControl`<br>`downbutton` — `TControl`<br>`foreground` — `TBrushObject`<br>`selection` — `TBrushObject`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState); TControl`<br>`upbutton` — `TControl` |
| `TPopupCell` — Редактор выбора из списка в ячейке.<br>[FMX.Grid.Style.pas:1096](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:1096>) | `TPopupBox` | `background` — `TTintedStyleObject / TTintedButtonStyleObject (ITintedObject)`<br>`content` — `TControl`<br>`foreground` — `TBrushObject`<br>`glyphstyle` — `TGlyph; TTintedGlyph / TTintedStyleObject (ITintedObject)`<br>`icon` — `TControl (ITintedObject)`<br>`text` — `TControl; TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TImageCell` — Контрол изображения в ячейке.<br>[FMX.Grid.Style.pas:1228](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:1228>) | `TImageControl` | `image` — `TControl; TImage` |
| `TCurrencyCell` — Денежный редактор ячейки на базе TNumberBox.<br>[FMX.Grid.Style.pas:1395](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:1395>) | `TNumberBox`<br>presentation: `TStyledNumberBox` | `background` — `TControl`<br>`buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject`<br>`text` — `TControl` |


### Цвета, изображения и Skia

| Класс и назначение | Непосредственный предок / представление | Элементы и классы с учётом наследования |
| --- | --- | --- |
| `THueTrackBar` — Выбор цветового тона на растровом треке.<br>[FMX.Colors.pas:27](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Colors.pas:27>) | `TBitmapTrackBar` | `hthumb` — `TThumb`<br>`htrack` — `TControl`<br>`thumb` — `TThumb`<br>`thumbsize` — `TStyleTag`<br>`track` — `TControl`<br>`vthumb` — `TThumb`<br>`vtrack` — `TControl`<br>`внутри htrack/vtrack → background` — `TRectangle`<br>`внутри track/htrack/vtrack → highlight` — `TControl` |
| `TAlphaTrackBar` — Выбор прозрачности на растровом треке.<br>[FMX.Colors.pas:40](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Colors.pas:40>) | `TBitmapTrackBar` | `hthumb` — `TThumb`<br>`htrack` — `TControl`<br>`thumb` — `TThumb`<br>`thumbsize` — `TStyleTag`<br>`track` — `TControl`<br>`vthumb` — `TThumb`<br>`vtrack` — `TControl`<br>`внутри htrack/vtrack → background` — `TRectangle`<br>`внутри track/htrack/vtrack → highlight` — `TControl` |
| `TBWTrackBar` — Выбор яркости между чёрным и белым.<br>[FMX.Colors.pas:60](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Colors.pas:60>) | `TBitmapTrackBar` | `hthumb` — `TThumb`<br>`htrack` — `TControl`<br>`thumb` — `TThumb`<br>`thumbsize` — `TStyleTag`<br>`track` — `TControl`<br>`vthumb` — `TThumb`<br>`vtrack` — `TControl`<br>`внутри htrack/vtrack → background` — `TRectangle`<br>`внутри track/htrack/vtrack → highlight` — `TControl` |
| `TComboColorBox` — Контрол выбора цвета со всплывающим содержимым.<br>[FMX.Colors.pas:499](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Colors.pas:499>) | `TStyledControl` | `Content` — `TControl` |
| `TColorButton` — Кнопка с фигурой образца выбранного цвета.<br>[FMX.Colors.pas:602](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Colors.pas:602>) | `TCustomButton` | `background` — `TTintedStyleObject / TTintedButtonStyleObject (ITintedObject)`<br>`fill` — `TShape`<br>`foreground` — `TBrushObject`<br>`glyphstyle` — `TGlyph; TTintedGlyph / TTintedStyleObject (ITintedObject)`<br>`icon` — `TControl (ITintedObject)`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TColorListBox` — Список цветов с фигурой color в стиле каждой строки.<br>[FMX.Colors.pas:690](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Colors.pas:690>) | `TCustomListBox` | `AlternatingRowBackground` — `TBrushObject (IBrushObject)`<br>`background` — `TControl`<br>`content` — `TControl`<br>`extendedselection` — `TControl`<br>`focusedselection` — `TControl`<br>`footer` — `TControl`<br>`header` — `TControl`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`selection` — `TControl`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar`<br>`элемент списка → color` — `TShape` |
| `TCustomColorComboBox` — База выпадающего списка цветов.<br>[FMX.Colors.pas:780](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Colors.pas:780>) | `TCustomComboBox` | `Content` — `TControl`<br>`элемент списка → color` — `TShape` |
| `TColorComboBox` — Выпадающий список цветов.<br>[FMX.Colors.pas:799](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Colors.pas:799>) | `TCustomColorComboBox` | `Content` — `TControl`<br>`элемент списка → color` — `TShape` |
| `TDropTarget` — Область приёма перетаскиваемых объектов с подписью.<br>[FMX.ExtCtrls.pas:24](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ExtCtrls.pas:24>) | `TTextControl` | `foreground` — `TBrushObject`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TImageViewer` — Просмотрщик изображения с прокруткой.<br>[FMX.ExtCtrls.pas:181](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ExtCtrls.pas:181>) | `TCustomScrollBox` | `background` — `TControl`<br>`content` — `TControl`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TPopupBox` — Кнопка выбора из набора строк через всплывающее меню.<br>[FMX.ExtCtrls.pas:283](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ExtCtrls.pas:283>) | `TCustomButton` | `background` — `TTintedStyleObject / TTintedButtonStyleObject (ITintedObject)`<br>`foreground` — `TBrushObject`<br>`glyphstyle` — `TGlyph; TTintedGlyph / TTintedStyleObject (ITintedObject)`<br>`icon` — `TControl (ITintedObject)`<br>`text` — `TControl / TText (ITextSettings, ICaption, IObjectState)` |
| `TSkStyledControl` — Базовый Skia-контрол с FMX-ресурсом стиля.<br>[FMX.Skia.pas:184](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Skia.pas:184>) | `TStyledControl` | Фиксированные имена частей не найдены; см. примечания о корне/представлении. |
| `TSkLabel` — Текстовая подпись Skia с настройками от корня или объекта text.<br>[FMX.Skia.pas:915](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Skia.pas:915>) | `TSkStyledControl` | `text` — `TSkStyleTextObject / TText / TStyleTextObject (ISkStyleTextObject, ITextSettings)` |


### MultiView и вспомогательные контейнеры

| Класс и назначение | Непосредственный предок / представление | Элементы и классы с учётом наследования |
| --- | --- | --- |
| `TCustomMultiView` — База адаптивного master/detail контейнера.<br>[FMX.MultiView.pas:155](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.MultiView.pas:155>) | `TPresentedControl` | `dropline` — `TBrushObject` |
| `TMultiView` — Адаптивная панель с несколькими способами показа master.<br>[FMX.MultiView.pas:281](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.MultiView.pas:281>) | `TCustomMultiView` | `dropline` — `TBrushObject` |
| `TCustomTouchInterceptingLayout` — База контейнера перехвата касаний MultiView.<br>[FMX.MultiView.Types.pas:69](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.MultiView.Types.pas:69>) | `TPresentedControl`<br>presentation: `TStyledTouchInterceptingLayout` | Фиксированные имена частей не найдены; см. примечания о корне/представлении. |
| `TTouchInterceptingLayout` — Контейнер перехвата касаний с presentation.<br>[FMX.MultiView.Types.pas:110](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.MultiView.Types.pas:110>) | `TCustomTouchInterceptingLayout`<br>presentation: `TStyledTouchInterceptingLayout` | Фиксированные имена частей не найдены; см. примечания о корне/представлении. |
| `TCustomPopover` — Всплывающая панель со стрелками четырёх направлений.<br>[FMX.MultiView.Types.pas:127](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.MultiView.Types.pas:127>) | `TPopup` | `arrow-bottom` — `TControl (ITintedObject)`<br>`arrow-content-bottom` — `TControl`<br>`arrow-content-left` — `TControl`<br>`arrow-content-right` — `TControl`<br>`arrow-content-top` — `TControl`<br>`arrow-left` — `TControl (ITintedObject)`<br>`arrow-right` — `TControl (ITintedObject)`<br>`arrow-top` — `TControl (ITintedObject)`<br>`background` — `TControl`<br>`bg` — `TTintedStyleObject / TTintedButtonStyleObject (ITintedObject)`<br>`content` — `TControl` |
| `TPopupPicker` — Внутренний popup стандартного FMX-пикера.<br>[FMX.Pickers.Default.pas:31](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Pickers.Default.pas:31>) | `TPopup` | `background` — `TControl` |
| `TPopupDateTimePicker` — Popup выбора даты/времени, наследующий оформление TPopupPicker.<br>[FMX.Pickers.Default.pas:49](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Pickers.Default.pas:49>) | `TPopupPicker` | `background` — `TControl` |
| `TPopupListPicker` — Popup выбора значения из списка, наследующий оформление TPopupPicker.<br>[FMX.Pickers.Default.pas:73](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Pickers.Default.pas:73>) | `TPopupPicker` | `background` — `TControl` |

**TCustomMultiView**. dropline читает TMultiViewBaseBorderedPresentation.UpdateStyle через MultiView.FindStyleResource<TBrushObject>. Другие варианты представления могут не использовать эту кисть.


### Styled представления

| Класс и назначение | Непосредственный предок / представление | Элементы и классы с учётом наследования |
| --- | --- | --- |
| `TStyledEdit` — Новое представление однострочного редактора из FMX.Edit.Style.New.<br>[FMX.Edit.Style.New.pas:66](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.Style.New.pas:66>) | `TStyledPresentation` | `buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TStyledEditBox` — Числовая база, наследующая новое TStyledEdit.<br>[FMX.EditBox.Style.pas:23](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.EditBox.Style.pas:23>) | `TStyledEdit` | `buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TStyledNumberBox` — Представление числового редактора.<br>[FMX.NumberBox.Style.pas:23](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.NumberBox.Style.pas:23>) | `TStyledEditBox` | `buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TStyledSpinBox` — Числовое представление с кнопками минус/плюс.<br>[FMX.SpinBox.Style.pas:23](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.SpinBox.Style.pas:23>) | `TStyledEditBox` | `buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`minusbutton` — `TCustomButton`<br>`plusbutton` — `TCustomButton`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TStyledComboEditBase` — Базовое представление ввода со стрелкой раскрытия.<br>[FMX.ComboEdit.Style.pas:46](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ComboEdit.Style.pas:46>) | `TStyledEdit` | `arrow` — `TControl`<br>`buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TStyledComboEdit` — Представление ComboEdit с дополнительным расчётом popup.<br>[FMX.ComboEdit.Style.pas:71](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ComboEdit.Style.pas:71>) | `TStyledComboEditBase` | `arrow` — `TControl`<br>`buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`Content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TStyledCalendarEdit` — Представление календарного ввода на базе ComboEdit.<br>[FMX.CalendarEdit.Style.pas:21](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.CalendarEdit.Style.pas:21>) | `TStyledComboEdit` | `arrow` — `TControl`<br>`buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`Content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TStyledComboTrackBar` — Представление редактора со всплывающим ползунком.<br>[FMX.ComboTrackBar.Style.pas:24](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ComboTrackBar.Style.pas:24>) | `TStyledEditBox` | `arrow` — `TControl`<br>`buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TStyledSearchBox` — Представление строки поиска.<br>[FMX.SearchBox.Style.pas:23](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.SearchBox.Style.pas:23>) | `TStyledEdit` | `buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`clearbutton` — `TEditButton`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`magglass` — `TEditButton`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TStyledMaskEdit` — Представление ввода по маске.<br>[FMX.MaskEdit.Style.pas:21](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.MaskEdit.Style.pas:21>) | `TStyledEdit` | `buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| `TStyledMemo` — Новое представление многострочного редактора из FMX.Memo.Style.New.<br>[FMX.Memo.Style.New.pas:47](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Memo.Style.New.pas:47>) | `TStyledCustomScrollBox` | `background` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TStyledCalendar` — Представление календаря с именованными частями.<br>[FMX.Calendar.Style.pas:24](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Calendar.Style.pas:24>) | `TStyledPresentation` | `days` — `TListBox`<br>`months` — `TPopupBox`<br>`next` — `TButton`<br>`prev` — `TButton`<br>`today` — `TButton`<br>`week` — `TGridLayout`<br>`weeks` — `TGridLayout`<br>`years` — `TPopupBox` |
| `TStyledCustomScrollBox` — Представление контейнера прокрутки.<br>[FMX.ScrollBox.Style.pas:51](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ScrollBox.Style.pas:51>) | `TStyledPresentation` | `background` — `TControl`<br>`content` — `TControl`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TStyledGrid` — Представление таблицы с кистями, заголовком, фокусом и выделением.<br>[FMX.Grid.Style.pas:53](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:53>) | `TStyledCustomScrollBox` | `AlternatingRowBackground` — `TBrushObject`<br>`background` — `TControl`<br>`content` — `TControl`<br>`EditorBackground` — `TBrushObject`<br>`EditorLineFill` — `TBrushObject`<br>`focus` — `TControl`<br>`header` — `THeader`<br>`hscrollbar` — `TScrollBar`<br>`hsmallscrollbar` — `TScrollBar`<br>`LineFill` — `TBrushObject`<br>`selection` — `TControl`<br>`sizegrip` — `TControl`<br>`vscrollbar` — `TScrollBar`<br>`vsmallscrollbar` — `TScrollBar` |
| `TStyledSwitch` — Представление переключателя с контрактом типа корня.<br>[FMX.Switch.Style.pas:24](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Switch.Style.pas:24>) | `TStyledPresentation` | Фиксированные имена частей не найдены; см. примечания о корне/представлении. |
| `TStyledTouchInterceptingLayout` — Представление контейнера перехвата касаний.<br>[FMX.MultiView.Types.Style.pas:22](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.MultiView.Types.Style.pas:22>) | `TStyledPresentation` | Фиксированные имена частей не найдены; см. примечания о корне/представлении. |

**TStyledSwitch**. ResourceLink должен быть TCustomSwitchObject или потомком для привязки Value, Control и OnChange. Это требование к типу корня, не к имени вложенной части.

## Подробные контракты классов, выполняющих поиск

Таблицы показывают **собственные обращения** каждого класса. Предки здесь не продублированы: их части уже добавлены в суммарный каталог. ItemData, selectors и бордюрное представление MultiView включены, поскольку выполняют часть поисков за контрол.

### TAniIndicator

Анимированный индикатор ожидания. Предок: `TStyledControl`.

При отсутствии ani создаётся внутренний TFloatAnimation. text служит источником цвета и очищается; fill должен поддерживать IBrushObject.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `ani` | `TAnimation` | `TFloatAnimation` | Self | Анимация ожидания. | `TAniIndicator.ApplyStyle`<br>[FMX.StdCtrls.pas:7931](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:7931>) |
| `fill` | `TFmxObject + IBrushObject` | `TBrushObject` | Self | Кисть/фигура заливки. | `TAniIndicator.ApplyStyle`<br>[FMX.StdCtrls.pas:7929](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:7929>) |
| `text` | `TText` | `TText` | Self | TText служит источником цвета; его текст очищается. | `TAniIndicator.ApplyStyle`<br>[FMX.StdCtrls.pas:7923](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:7923>) |

### TArcDial

Круговой регулятор угла с указателем и подписями. Предок: `TPresentedControl`.

Поиски выполняются в Tick и Text, вызываемых из ApplyStyle и при изменении значения.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `text` | `TText` | `TText` | Self | Текст и параметры подписи. | `TArcDial.Text`<br>[FMX.StdCtrls.pas:8272](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:8272>) |
| `tick` | `TControl; IRotatedControl для поворота` | `TPath`, `TRectangle`, `TLayout` | Self | Поворотный указатель. | `TArcDial.Tick`<br>[FMX.StdCtrls.pas:8209](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:8209>) |
| `tracktext` | `TText` | `TText` | Self | Подпись угла при изменении. | `TArcDial.Text`<br>[FMX.StdCtrls.pas:8262](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:8262>) |

### TBitmapTrackBar

Ползунок с растровым изображением фона трека. Предок: `TTrackBar`.

background ищется внутри htrack/vtrack, а не как фон корня; ожидается TRectangle для рисования bitmap.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `background` | `TRectangle` | `TRectangle` | внутри htrack/vtrack | Фон контрола. | `TBitmapTrackBar.ApplyStyle`<br>[FMX.StdCtrls.pas:7031](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:7031>) |
| `htrack` | `TControl` | `TLayout`, `TRectangle` | Self | Горизонтальный трек. | `TBitmapTrackBar.ApplyStyle`<br>[FMX.StdCtrls.pas:7023](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:7023>) |
| `vtrack` | `TControl` | `TLayout`, `TRectangle` | Self | Вертикальный трек. | `TBitmapTrackBar.ApplyStyle`<br>[FMX.StdCtrls.pas:7041](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:7041>) |

### TCalloutPanel

Панель с выступающим указателем. Предок: `TPanel`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `Background` | `TCalloutRectangle` | `TCalloutRectangle` | Self | Фон контрола. | `TCalloutPanel.ApplyStyle`<br>[FMX.StdCtrls.pas:3523](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:3523>) |

### TCellText

Внутреннее текстовое оформление ячейки. Предок: `TTextControl`.

Собственный ApplyStyle загружает font/foreground; text также унаследован от TTextControl. Это внутренний контрол ячейки.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `font` | `TFontObject` | `TFontObject` | Self | Шрифт текста. | `TCellText.ApplyStyle`<br>[FMX.Grid.Style.pas:561](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:561>) |
| `foreground` | `TBrushObject` | `TBrushObject` | Self | Цвет текста из кисти. | `TCellText.ApplyStyle`<br>[FMX.Grid.Style.pas:563](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:563>) |

### TCheckCell

Флажок редактора логической ячейки. Предок: `TCheckBox`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `background` | `TControl` | `TRectangle`, `TStyleObject` | Self | Фон контрола. | `TCheckCell.ApplyStyle`<br>[FMX.Grid.Style.pas:797](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:797>) |

### TColorButton

Кнопка с фигурой образца выбранного цвета. Предок: `TCustomButton`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `fill` | `TShape` | `TRectangle`, `TCircle`, `TPath` | Self | Фигура, которой назначается выбранный цвет. | `TColorButton.ApplyStyle`<br>[FMX.Colors.pas:2225](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Colors.pas:2225>) |

### TColorListBox

Список цветов с фигурой color в стиле каждой строки. Предок: `TCustomListBox`.

color ищется в стиле TListBoxItem(Sender) при DoItemApplyStyleLookup. Это часть ресурса строки, а не корня listboxstyle.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `color` | `TShape` | `TRectangle`, `TCircle`, `TPath` | стиль элемента списка | Образец цвета строки. | `TColorListBox.DoItemApplyStyleLookup`<br>[FMX.Colors.pas:2378](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Colors.pas:2378>) |

### TComboColorBox

Контрол выбора цвета со всплывающим содержимым. Предок: `TStyledControl`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `Content` | `TControl` | `TLayout`, `TRectangle` | Self | Контейнер/область содержимого. | `TComboColorBox.ApplyStyle`<br>[FMX.Colors.pas:2155](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Colors.pas:2155>) |

### TCurrencyCell

Денежный редактор ячейки на базе TNumberBox. Предок: `TNumberBox`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `background` | `TControl` | `TRectangle`, `TStyleObject` | Self | Фон контрола. | `TCurrencyCell.ApplyStyle`<br>[FMX.Grid.Style.pas:1440](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:1440>) |
| `content` | `TControl` | `TLayout`, `TRectangle` | Self | Контейнер/область содержимого. | `TCurrencyCell.ApplyStyle`<br>[FMX.Grid.Style.pas:1435](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:1435>) |
| `text` | `TControl` | `TText`, `TLabel` | Self | Текст и параметры подписи. | `TCurrencyCell.ApplyStyle`<br>[FMX.Grid.Style.pas:1434](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:1434>) |

### TCustomButton

База кнопок с текстом, глифом и оттенком оформления. Предок: `TPresentedTextControl`.

`glyphstyle` ожидается как TGlyph для Images/ImageIndex. `icon` и `glyphstyle` также проверяются на ITintedObject для IconTintColor; background — для TintColor. text/foreground приходят от TPresentedTextControl.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `background` | `TFmxObject; ITintedObject для TintColor` | `TTintedStyleObject`, `TTintedButtonStyleObject` | Self | ITintedObject получает TintColor. | `TCustomButton.ApplyStyle`<br>[FMX.StdCtrls.pas:4113](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:4113>) |
| `glyphstyle` | `TGlyph для Images/ImageIndex` | `TGlyph`, `TTintedGlyph` | Self | Глиф, связанный с Images/ImageIndex. | `TCustomButton.ApplyStyle`<br>[FMX.StdCtrls.pas:4115](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:4115>) |
| `glyphstyle` | `TFmxObject; ITintedObject для IconTintColor` | `TTintedGlyph`, `TTintedStyleObject` | Self | Глиф, связанный с Images/ImageIndex. | `TCustomButton.ApplyStyle`<br>[FMX.StdCtrls.pas:4130](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:4130>) |
| `icon` | `TFmxObject; ITintedObject для IconTintColor; TControl для FIcon` | `TTintedStyleObject`, `TTintedButtonStyleObject`, `TTintedGlyph` | Self | ITintedObject получает IconTintColor; TControl сохраняется как FIcon. | `TCustomButton.ApplyStyle`<br>[FMX.StdCtrls.pas:4129](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:4129>) |

### TCustomColorComboBox

База выпадающего списка цветов. Предок: `TCustomComboBox`.

color ищется в стиле строки выпадающего списка; Content — в собственном стиле ComboBox.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `color` | `TShape` | `TRectangle`, `TCircle`, `TPath` | стиль элемента списка | Образец цвета строки. | `TCustomColorComboBox.DoItemApplyStyleLookup`<br>[FMX.Colors.pas:2476](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Colors.pas:2476>) |

### TCustomComboBox

База выпадающего выбора с областью текущего элемента. Предок: `TStyledControl`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `Content` | `TControl` | `TLayout`, `TRectangle` | Self | Контейнер/область содержимого. | `TCustomComboBox.ApplyStyle`<br>[FMX.ListBox.pas:4006](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:4006>) |
| `Content` | `TControl` | `TLayout`, `TRectangle` | Self | Контейнер/область содержимого. | `TCustomComboBox.RecalculatePopupSize`<br>[FMX.ListBox.pas:4282](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:4282>) |
| `Content` | `TControl` | `TLayout`, `TRectangle` | Self | Контейнер/область содержимого. | `TCustomComboBox.UpdateCurrentItem`<br>[FMX.ListBox.pas:4045](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:4045>) |

### TCustomCornerButton

Кнопка с настраиваемыми углами фона. Предок: `TCustomButton`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `Background` | `TRectangle` | `TRectangle` | Self | Фон контрола. | `TCustomCornerButton.ApplyStyle`<br>[FMX.StdCtrls.pas:4663](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:4663>) |
| `SecondBackground` | `TRectangle` | `TRectangle` | Self | Второй прямоугольник фона. | `TCustomCornerButton.ApplyStyle`<br>[FMX.StdCtrls.pas:4671](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:4671>) |

### TCustomDateEdit

База редактора даты из FMX.DateTimeCtrls. Предок: `TCustomDateTimeEdit`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `arrow` | `TControl` | `TPath`, `TButton` | Self | Раскрытие всплывающего выбора. | `TCustomDateEdit.ApplyStyle`<br>[FMX.DateTimeCtrls.pas:1640](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.DateTimeCtrls.pas:1640>) |

### TCustomDateTimeEdit

База составного редактора даты/времени с очисткой и флажком. Предок: `TTextControl`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `check` | `TCheckBox` | `TCheckBox` | Self | Встроенный флажок. | `TCustomDateTimeEdit.ApplyStyle`<br>[FMX.DateTimeCtrls.pas:446](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.DateTimeCtrls.pas:446>) |
| `clearbutton` | `TControl` | `TButton`, `TEditButton` | Self | Очистка значения. | `TCustomDateTimeEdit.ApplyStyle`<br>[FMX.DateTimeCtrls.pas:455](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.DateTimeCtrls.pas:455>) |
| `selection` | `TBrushObject` | `TBrushObject` | Self | Оформление выделения. | `TCustomDateTimeEdit.ApplyStyle`<br>[FMX.DateTimeCtrls.pas:469](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.DateTimeCtrls.pas:469>) |

### TCustomGrid

База таблицы с отдельным styled представлением. Предок: `TCustomPresentedScrollBox`.

Поиски массива StyleNames в ApplyStyle скрывают части только при отсутствии presentation proxy. Нормальное styled отображение выполняет TStyledGrid.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `content` | `TControl` | `TLayout`, `TRectangle` | Self | Контейнер/область содержимого. Массив StyleNames; скрытие только при отсутствии presentation proxy. | `TCustomGrid.ApplyStyle`<br>[FMX.Grid.pas:4441](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.pas:4441>) |
| `header` | `TControl` | `TLayout`, `TRectangle` | Self | Область/контрол заголовка. Массив StyleNames; скрытие только при отсутствии presentation proxy. | `TCustomGrid.ApplyStyle`<br>[FMX.Grid.pas:4441](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.pas:4441>) |
| `hscrollbar` | `TControl` | `TScrollBar`, `TSmallScrollBar` | Self | Обычная горизонтальная полоса. Массив StyleNames; скрытие только при отсутствии presentation proxy. | `TCustomGrid.ApplyStyle`<br>[FMX.Grid.pas:4441](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.pas:4441>) |
| `hsmallscrollbar` | `TControl` | `TScrollBar`, `TSmallScrollBar` | Self | Компактная горизонтальная полоса. Массив StyleNames; скрытие только при отсутствии presentation proxy. | `TCustomGrid.ApplyStyle`<br>[FMX.Grid.pas:4442](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.pas:4442>) |
| `vscrollbar` | `TControl` | `TScrollBar`, `TSmallScrollBar` | Self | Обычная вертикальная полоса. Массив StyleNames; скрытие только при отсутствии presentation proxy. | `TCustomGrid.ApplyStyle`<br>[FMX.Grid.pas:4441](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.pas:4441>) |
| `vsmallscrollbar` | `TControl` | `TScrollBar`, `TSmallScrollBar` | Self | Компактная вертикальная полоса. Массив StyleNames; скрытие только при отсутствии presentation proxy. | `TCustomGrid.ApplyStyle`<br>[FMX.Grid.pas:4441](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.pas:4441>) |

### TCustomListBox

База списка с прокруткой, выделением и чередованием фона. Предок: `TScrollBox`.

focusedselection/extendedselection могут заменяться selection. AlternatingRowBackground требует IBrushObject. Элементы списка используют собственные стили TListBoxItem.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `AlternatingRowBackground` | `TFmxObject + IBrushObject` | `TBrushObject` | Self | Кисть чередующихся строк. | `TCustomListBox.ApplyStyle`<br>[FMX.ListBox.pas:1998](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:1998>) |
| `extendedselection` | `TControl` | `TRectangle`, `TStyleObject` | Self | Расширенное выделение списка. | `TCustomListBox.ApplyStyle`<br>[FMX.ListBox.pas:1989](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:1989>) |
| `focusedselection` | `TControl` | `TRectangle`, `TStyleObject` | Self | Выделение при фокусе. | `TCustomListBox.ApplyStyle`<br>[FMX.ListBox.pas:1976](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:1976>) |
| `footer` | `TControl` | `TLayout`, `TRectangle` | Self | Нижняя область списка. | `TCustomListBox.ApplyStyle`<br>[FMX.ListBox.pas:2012](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:2012>) |
| `header` | `TControl` | `TLayout`, `TRectangle` | Self | Область/контрол заголовка. | `TCustomListBox.ApplyStyle`<br>[FMX.ListBox.pas:2004](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:2004>) |
| `selection` | `TControl` | `TRectangle`, `TStyleObject` | Self | Оформление выделения. | `TCustomListBox.ApplyStyle`<br>[FMX.ListBox.pas:1971](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:1971>) |

### TCustomMagnifierGlass

База экранной лупы. Предок: `TPresentedControl`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `content` | `TShape` | `TRectangle`, `TCircle`, `TPath` | Self | Контейнер/область содержимого. | `TCustomMagnifierGlass.ApplyStyle`<br>[FMX.MagnifierGlass.pas:219](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.MagnifierGlass.pas:219>) |

### TCustomPopover

Всплывающая панель со стрелками четырёх направлений. Предок: `TPopup`.

arrow-content-%s и arrow-%s развёрнуты для top/bottom/left/right. background приходит от TPopup; bg/content добавляются здесь.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `arrow-bottom` | `TControl; ITintedObject для tint (проверяется отдельно)` | `TTintedStyleObject`, `TTintedGlyph`, `TPath` | Self | Стрелка bottom. Format с направлением стрелки; tint дополнительно требует ITintedObject. | `TCustomPopover.ApplyStyle`<br>[FMX.MultiView.Types.pas:798](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.MultiView.Types.pas:798>) |
| `arrow-content-bottom` | `TControl` | `TLayout`, `TRectangle` | Self | Контейнер стрелки bottom. Format с направлением стрелки; tint дополнительно требует ITintedObject. | `TCustomPopover.ApplyStyle`<br>[FMX.MultiView.Types.pas:798](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.MultiView.Types.pas:798>) |
| `arrow-content-left` | `TControl` | `TLayout`, `TRectangle` | Self | Контейнер стрелки left. Format с направлением стрелки; tint дополнительно требует ITintedObject. | `TCustomPopover.ApplyStyle`<br>[FMX.MultiView.Types.pas:798](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.MultiView.Types.pas:798>) |
| `arrow-content-right` | `TControl` | `TLayout`, `TRectangle` | Self | Контейнер стрелки right. Format с направлением стрелки; tint дополнительно требует ITintedObject. | `TCustomPopover.ApplyStyle`<br>[FMX.MultiView.Types.pas:798](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.MultiView.Types.pas:798>) |
| `arrow-content-top` | `TControl` | `TLayout`, `TRectangle` | Self | Контейнер стрелки top. Format с направлением стрелки; tint дополнительно требует ITintedObject. | `TCustomPopover.ApplyStyle`<br>[FMX.MultiView.Types.pas:798](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.MultiView.Types.pas:798>) |
| `arrow-left` | `TControl; ITintedObject для tint (проверяется отдельно)` | `TTintedStyleObject`, `TTintedGlyph`, `TPath` | Self | Стрелка left. Format с направлением стрелки; tint дополнительно требует ITintedObject. | `TCustomPopover.ApplyStyle`<br>[FMX.MultiView.Types.pas:798](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.MultiView.Types.pas:798>) |
| `arrow-right` | `TControl; ITintedObject для tint (проверяется отдельно)` | `TTintedStyleObject`, `TTintedGlyph`, `TPath` | Self | Стрелка right. Format с направлением стрелки; tint дополнительно требует ITintedObject. | `TCustomPopover.ApplyStyle`<br>[FMX.MultiView.Types.pas:798](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.MultiView.Types.pas:798>) |
| `arrow-top` | `TControl; ITintedObject для tint (проверяется отдельно)` | `TTintedStyleObject`, `TTintedGlyph`, `TPath` | Self | Стрелка top. Format с направлением стрелки; tint дополнительно требует ITintedObject. | `TCustomPopover.ApplyStyle`<br>[FMX.MultiView.Types.pas:798](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.MultiView.Types.pas:798>) |
| `bg` | `TFmxObject + ITintedObject` | `TTintedStyleObject`, `TTintedButtonStyleObject` | Self | Тонируемый фон popover. | `TCustomPopover.ApplyStyle`<br>[FMX.MultiView.Types.pas:829](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.MultiView.Types.pas:829>) |
| `content` | `TControl` | `TLayout`, `TRectangle` | Self | Контейнер/область содержимого. | `TCustomPopover.ApplyStyle`<br>[FMX.MultiView.Types.pas:833](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.MultiView.Types.pas:833>) |

### TCustomScrollBox

Styled контейнер прокрутки из FMX.Layouts без отдельного presentation. Предок: `TStyledControl`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `background` | `TControl` | `TRectangle`, `TStyleObject` | Self | Фон контрола. | `TCustomScrollBox.ApplyStyle`<br>[FMX.Layouts.pas:1928](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Layouts.pas:1928>) |
| `content` | `TControl` | `TLayout`, `TRectangle` | Self | Контейнер/область содержимого. | `TCustomScrollBox.ApplyStyle`<br>[FMX.Layouts.pas:1954](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Layouts.pas:1954>) |
| `hscrollbar` | `TScrollBar` | `TScrollBar`, `TSmallScrollBar` | Self | Обычная горизонтальная полоса. Имя передаётся локальной процедуре; варианты осей и компактного оформления. | `TCustomScrollBox.ApplyStyle`<br>[FMX.Layouts.pas:1931](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Layouts.pas:1931>) |
| `hsmallscrollbar` | `TScrollBar` | `TScrollBar`, `TSmallScrollBar` | Self | Компактная горизонтальная полоса. Имя передаётся локальной процедуре; варианты осей и компактного оформления. | `TCustomScrollBox.ApplyStyle`<br>[FMX.Layouts.pas:1933](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Layouts.pas:1933>) |
| `sizegrip` | `TControl` | `TSizeGrip`, `TRectangle` | Self | Ручка изменения размера. | `TCustomScrollBox.ApplyStyle`<br>[FMX.Layouts.pas:1935](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Layouts.pas:1935>) |
| `vscrollbar` | `TScrollBar` | `TScrollBar`, `TSmallScrollBar` | Self | Обычная вертикальная полоса. Имя передаётся локальной процедуре; варианты осей и компактного оформления. | `TCustomScrollBox.ApplyStyle`<br>[FMX.Layouts.pas:1930](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Layouts.pas:1930>) |
| `vsmallscrollbar` | `TScrollBar` | `TScrollBar`, `TSmallScrollBar` | Self | Компактная вертикальная полоса. Имя передаётся локальной процедуре; варианты осей и компактного оформления. | `TCustomScrollBox.ApplyStyle`<br>[FMX.Layouts.pas:1932](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Layouts.pas:1932>) |

### TCustomTimeEdit

База редактора времени с кнопками вверх/вниз. Предок: `TCustomDateTimeEdit`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `downbutton` | `TControl` | `TButton`, `TEditButton` | Self | Уменьшение значения. | `TCustomTimeEdit.ApplyStyle`<br>[FMX.DateTimeCtrls.pas:717](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.DateTimeCtrls.pas:717>) |
| `upbutton` | `TControl` | `TButton`, `TEditButton` | Self | Увеличение значения. | `TCustomTimeEdit.ApplyStyle`<br>[FMX.DateTimeCtrls.pas:711](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.DateTimeCtrls.pas:711>) |

### TCustomTrack

База трека диапазона с бегунком и подсветкой. Предок: `TPresentedControl`.

hthumb/vthumb/thumb и htrack/vtrack/track — альтернативы по ориентации и наличию объектов. highlight ищется внутри выбранного FTrack. thumbsize читается как числовой Tag/TagFloat у TFmxObject, а не геометрический размер.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `highlight` | `TControl` | `TRectangle`, `TStyleObject` | внутри track/htrack/vtrack | Подсветка части трека. | `TCustomTrack.ApplyStyle`<br>[FMX.StdCtrls.pas:6598](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:6598>) |
| `hthumb` | `TThumb` | `TThumb` | Self | Горизонтальный бегунок. | `TCustomTrack.ApplyStyle`<br>[FMX.StdCtrls.pas:6556](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:6556>) |
| `htrack` | `TControl` | `TLayout`, `TRectangle` | Self | Горизонтальный трек. | `TCustomTrack.ApplyStyle`<br>[FMX.StdCtrls.pas:6581](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:6581>) |
| `thumb` | `TThumb` | `TThumb` | Self | Общий бегунок. | `TCustomTrack.ApplyStyle`<br>[FMX.StdCtrls.pas:6566](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:6566>) |
| `thumbsize` | `TFmxObject; положительный Tag/TagFloat` | `TStyleTag` | Self | Размер бегунка из Tag/TagFloat. | `TCustomTrack.ApplyStyle`<br>[FMX.StdCtrls.pas:6626](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:6626>) |
| `track` | `TControl` | `TLayout`, `TRectangle` | Self | Общий/запасной вариант трека. | `TCustomTrack.ApplyStyle`<br>[FMX.StdCtrls.pas:6591](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:6591>) |
| `vthumb` | `TThumb` | `TThumb` | Self | Вертикальный бегунок. | `TCustomTrack.ApplyStyle`<br>[FMX.StdCtrls.pas:6546](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:6546>) |
| `vtrack` | `TControl` | `TLayout`, `TRectangle` | Self | Вертикальный трек. | `TCustomTrack.ApplyStyle`<br>[FMX.StdCtrls.pas:6571](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:6571>) |

### TCustomTreeView

База дерева с прокруткой и выделением. Предок: `TScrollBox`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `AlternatingRowBackground` | `TFmxObject + IBrushObject` | `TBrushObject` | Self | Кисть чередующихся строк. | `TCustomTreeView.ApplyStyle`<br>[FMX.TreeView.pas:1596](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.TreeView.pas:1596>) |
| `content` | `TControl` | `TLayout`, `TRectangle` | Self | Контейнер/область содержимого. | `TCustomTreeView.ApplyStyle`<br>[FMX.TreeView.pas:1590](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.TreeView.pas:1590>) |
| `focusedselection` | `TControl` | `TRectangle`, `TStyleObject` | Self | Выделение при фокусе. | `TCustomTreeView.ApplyStyle`<br>[FMX.TreeView.pas:1594](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.TreeView.pas:1594>) |
| `selection` | `TControl` | `TRectangle`, `TStyleObject` | Self | Оформление выделения. | `TCustomTreeView.ApplyStyle`<br>[FMX.TreeView.pas:1592](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.TreeView.pas:1592>) |

### TDateCell

Редактор даты в ячейке. Предок: `TCustomDateEdit`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `background` | `TControl` | `TRectangle`, `TStyleObject` | Self | Фон контрола. | `TDateCell.ApplyStyle`<br>[FMX.Grid.Style.pas:949](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:949>) |
| `content` | `TControl` | `TLayout`, `TRectangle` | Self | Контейнер/область содержимого. | `TDateCell.ApplyStyle`<br>[FMX.Grid.Style.pas:944](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:944>) |
| `text` | `TControl` | `TText`, `TLabel` | Self | Текст и параметры подписи. | `TDateCell.ApplyStyle`<br>[FMX.Grid.Style.pas:943](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:943>) |

### TDefaultEditor

Внутренний однострочный редактор ячейки. Предок: `TCustomEdit`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `content` | `TControl` | `TLayout`, `TRectangle` | Self | Контейнер/область содержимого. | `TDefaultEditor.ApplyStyle`<br>[FMX.Grid.Style.pas:445](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:445>) |

### TExpander

Раскрываемый контейнер с заголовком, флажком и кнопкой. Предок: `TTextControl`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `button` | `TCustomButton` | `TButton`, `TSpeedButton` | Self | Кнопка действия/раскрытия. | `TExpander.ApplyStyle`<br>[FMX.StdCtrls.pas:8476](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:8476>) |
| `checkbox` | `TCheckBox` | `TCheckBox` | Self | Флажок заголовка. | `TExpander.ApplyStyle`<br>[FMX.StdCtrls.pas:8470](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:8470>) |
| `header` | `TControl` | `TLayout`, `TRectangle` | Self | Область/контрол заголовка. | `TExpander.ApplyStyle`<br>[FMX.StdCtrls.pas:8464](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:8464>) |

### TImageCell

Контрол изображения в ячейке. Предок: `TImageControl`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `image` | `TControl` | `TLayout`, `TRectangle` | Self | Изображение. | `TImageCell.ApplyStyle`<br>[FMX.Grid.Style.pas:1319](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:1319>) |

### TImageControl

Контрол изображения с именованным TImage. Предок: `TStyledControl`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `image` | `TImage` | `TImage` | Self | Изображение. | `TImageControl.ApplyStyle`<br>[FMX.StdCtrls.pas:8757](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:8757>) |

### TInteractiveTextSelectors

Помощник новых текстовых представлений, обслуживающий маркеры выделения. Предок: `TNoRefCountObject`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `caretpoint` | `TSelectionPoint` | `TSelectionPoint` | Self (FOwner) | Маркер положения каретки. | `TInteractiveTextSelectors.ApplyStyle`<br>[FMX.Text.InteractiveSelectors.pas:233](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Text.InteractiveSelectors.pas:233>) |
| `leftselectionpoint` | `TSelectionPoint` | `TSelectionPoint` | Self (FOwner) | Маркер начала текстового выделения. | `TInteractiveTextSelectors.ApplyStyle`<br>[FMX.Text.InteractiveSelectors.pas:201](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Text.InteractiveSelectors.pas:201>) |
| `rightselectionpoint` | `TSelectionPoint` | `TSelectionPoint` | Self (FOwner) | Маркер конца текстового выделения. | `TInteractiveTextSelectors.ApplyStyle`<br>[FMX.Text.InteractiveSelectors.pas:218](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Text.InteractiveSelectors.pas:218>) |

### TListBoxItem

Строка списка с текстом, флажком, изображением и ItemData. Предок: `TTextControl`.

SelectBackground обращается к пяти фонам через StylesData[...Visible]. ItemData обслуживает detail и accessorymore/accessorydetail/accessorycheckmark вне ApplyStyle; эти поиски показаны в контракте TListBoxItemData.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `background_roundall` | `TControl` | `TRectangle`, `TStyleObject` | Self | Видимость соответствующего варианта фона строки. Через StylesData[background_roundall.Visible]; свойство Visible. | `TListBoxItem.SelectBackground`<br>[FMX.ListBox.pas:1409](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:1409>) |
| `background_roundbottom` | `TControl` | `TRectangle`, `TStyleObject` | Self | Видимость соответствующего варианта фона строки. Через StylesData[background_roundbottom.Visible]; свойство Visible. | `TListBoxItem.SelectBackground`<br>[FMX.ListBox.pas:1408](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:1408>) |
| `background_roundtop` | `TControl` | `TRectangle`, `TStyleObject` | Self | Видимость соответствующего варианта фона строки. Через StylesData[background_roundtop.Visible]; свойство Visible. | `TListBoxItem.SelectBackground`<br>[FMX.ListBox.pas:1407](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:1407>) |
| `background_separatorbottom` | `TControl` | `TRectangle`, `TStyleObject` | Self | Видимость соответствующего варианта фона строки. Через StylesData[background_separatorbottom.Visible]; свойство Visible. | `TListBoxItem.SelectBackground`<br>[FMX.ListBox.pas:1405](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:1405>) |
| `background_sharp` | `TControl` | `TRectangle`, `TStyleObject` | Self | Видимость соответствующего варианта фона строки. Через StylesData[background_sharp.Visible]; свойство Visible. | `TListBoxItem.SelectBackground`<br>[FMX.ListBox.pas:1406](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:1406>) |
| `check` | `TCheckBox` | `TCheckBox` | Self | Встроенный флажок. | `TListBoxItem.ApplyStyle`<br>[FMX.ListBox.pas:1124](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:1124>) |
| `glyphstyle` | `TGlyph` | `TGlyph`, `TTintedGlyph` | Self | Глиф, связанный с Images/ImageIndex. | `TListBoxItem.ApplyStyle`<br>[FMX.ListBox.pas:1137](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:1137>) |
| `icon` | `TImage` | `TImage` | Self | Изображение/иконка. | `TListBoxItem.ApplyStyle`<br>[FMX.ListBox.pas:1139](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:1139>) |

### TListBoxItemData

Данные и оформление дополнительных частей строки списка. Предок: `TPersistent`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `accessorycheckmark` | `TControl` | `TLayout`, `TRectangle` | Self (FItem) | Отметка строки. | `TListBoxItemData.Disappear`<br>[FMX.ListBox.pas:5383](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:5383>) |
| `accessorycheckmark` | `TControl` | `TLayout`, `TRectangle` | Self (FItem) | Отметка строки. Через StylesData[accessorycheckmark.Visible]; свойство Visible. | `TListBoxItemData.SetAccessory`<br>[FMX.ListBox.pas:5415](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:5415>) |
| `accessorydetail` | `TControl` | `TLayout`, `TRectangle` | Self (FItem) | Индикатор подробностей. | `TListBoxItemData.Disappear`<br>[FMX.ListBox.pas:5380](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:5380>) |
| `accessorydetail` | `TControl` | `TLayout`, `TRectangle` | Self (FItem) | Индикатор подробностей. Через StylesData[accessorydetail.Visible]; свойство Visible. | `TListBoxItemData.SetAccessory`<br>[FMX.ListBox.pas:5414](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:5414>) |
| `accessorymore` | `TControl` | `TLayout`, `TRectangle` | Self (FItem) | Индикатор перехода к деталям. | `TListBoxItemData.Disappear`<br>[FMX.ListBox.pas:5377](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:5377>) |
| `accessorymore` | `TControl` | `TLayout`, `TRectangle` | Self (FItem) | Индикатор перехода к деталям. Через StylesData[accessorymore.Visible]; свойство Visible. | `TListBoxItemData.SetAccessory`<br>[FMX.ListBox.pas:5413](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:5413>) |
| `detail` | `TFmxObject с Data типа string` | `TText`, `TLabel` | Self (FItem) | Дополнительный текст строки. Через StylesData[detail]; значение объекта. | `TListBoxItemData.GetDetail`<br>[FMX.ListBox.pas:5395](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:5395>) |
| `detail` | `TFmxObject с Data типа string` | `TText`, `TLabel` | Self (FItem) | Дополнительный текст строки. Через StylesData[detail]; значение объекта. | `TListBoxItemData.SetDetail`<br>[FMX.ListBox.pas:5442](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListBox.pas:5442>) |

### TListViewBase

ListView, загружающий цвета, шрифты и изображения оформления строк. Предок: `TAdapterListView`.

GetColorFromStyle, AssignFontFromStyle, GetStyleObjectFromStyle скрывают имена во вспомогательных функциях. Здесь развёрнуты все буквальные аргументы. selection сначала пробуют как TStyleObject, затем как цвет. Appearance drawables являются объектами строки, а не частями FMX-стиля.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `accessorycheckmark` | `TStyleObject` | `TStyleObject` | Self | Отметка строки. Через GetStyleObjectFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4608](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4608>) |
| `accessorycheckmarkselected` | `TStyleObject` | `TStyleObject` | Self | Выбранная отметка строки. Через GetStyleObjectFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4609](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4609>) |
| `accessorydetail` | `TStyleObject` | `TStyleObject` | Self | Индикатор подробностей. Через GetStyleObjectFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4610](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4610>) |
| `accessorydetailselected` | `TStyleObject` | `TStyleObject` | Self | Выбранный индикатор подробностей. Через GetStyleObjectFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4611](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4611>) |
| `accessorymore` | `TStyleObject` | `TStyleObject` | Self | Индикатор перехода к деталям. Через GetStyleObjectFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4606](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4606>) |
| `accessorymoreselected` | `TStyleObject` | `TStyleObject` | Self | Выбранный индикатор перехода. Через GetStyleObjectFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4607](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4607>) |
| `additembutton` | `TStyleObject` | `TStyleObject` | Self | Изображение кнопки добавления. Через GetStyleObjectFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4594](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4594>) |
| `additembuttonpressed` | `TStyleObject` | `TStyleObject` | Self | Изображение нажатого добавления. Через GetStyleObjectFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4595](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4595>) |
| `alternatingitembackground` | `TColorObject или TText` | `TColorObject`, `TText`, `TStyleTextObject` | Self | Цвет чередующихся строк. Через GetColorFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4557](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4557>) |
| `background` | `TColorObject или TText` | `TColorObject`, `TText`, `TStyleTextObject` | Self | Цвет фона списка. Через GetColorFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4554](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4554>) |
| `button` | `TStyleObject` | `TStyleObject` | Self | Изображение обычной кнопки строки. Через GetStyleObjectFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4598](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4598>) |
| `buttonfont` | `TFontObject или TText` | `TFontObject`, `TText`, `TStyleTextObject` | Self | Шрифт кнопки. Через AssignFontFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4576](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4576>) |
| `buttonpressed` | `TStyleObject` | `TStyleObject` | Self | Изображение нажатой кнопки. Через GetStyleObjectFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4599](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4599>) |
| `buttontext` | `TColorObject или TText` | `TColorObject`, `TText`, `TStyleTextObject` | Self | Цвет текста кнопки. Через GetColorFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4567](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4567>) |
| `buttontextpressed` | `TColorObject или TText` | `TColorObject`, `TText`, `TStyleTextObject` | Self | Цвет текста нажатой кнопки. Через GetColorFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4568](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4568>) |
| `checkboxchecked` | `TStyleObject` | `TStyleObject` | Self | Изображение установленного флажка. Через GetStyleObjectFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4603](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4603>) |
| `checkboxunchecked` | `TStyleObject` | `TStyleObject` | Self | Изображение неустановленного флажка. Через GetStyleObjectFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4602](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4602>) |
| `deletebutton` | `TStyleObject` | `TStyleObject` | Self | Изображение кнопки удаления. Через GetStyleObjectFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4600](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4600>) |
| `deletebuttonfont` | `TFontObject или TText` | `TFontObject`, `TText`, `TStyleTextObject` | Self | Шрифт кнопки удаления. Через AssignFontFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4577](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4577>) |
| `deletebuttonpressed` | `TStyleObject` | `TStyleObject` | Self | Изображение нажатого удаления. Через GetStyleObjectFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4601](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4601>) |
| `deletebuttontext` | `TColorObject или TText` | `TColorObject`, `TText`, `TStyleTextObject` | Self | Цвет текста кнопки удаления. Через GetColorFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4569](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4569>) |
| `deletebuttontextpressed` | `TColorObject или TText` | `TColorObject`, `TText`, `TStyleTextObject` | Self | Цвет текста нажатой кнопки удаления. Через GetColorFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4570](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4570>) |
| `deleteitembutton` | `TStyleObject` | `TStyleObject` | Self | Изображение удаления строки. Через GetStyleObjectFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4596](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4596>) |
| `deleteitembuttonglyph` | `TStyleObject` | `TStyleObject` | Self | Pressed-изображение удаления строки (так назначается в коде). Через GetStyleObjectFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4597](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4597>) |
| `detailfont` | `TFontObject или TText` | `TFontObject`, `TText`, `TStyleTextObject` | Self | Шрифт дополнительного текста. Через AssignFontFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4574](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4574>) |
| `detailtext` | `TColorObject или TText` | `TColorObject`, `TText`, `TStyleTextObject` | Self | Цвет дополнительного текста. Через GetColorFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4563](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4563>) |
| `font` | `TFontObject или TText` | `TFontObject`, `TText`, `TStyleTextObject` | Self | Шрифт текста. Через AssignFontFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4573](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4573>) |
| `foreground` | `TColorObject или TText` | `TColorObject`, `TText`, `TStyleTextObject` | Self | Цвет текста из кисти. Через GetColorFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4561](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4561>) |
| `frame` | `TColorObject или TText` | `TColorObject`, `TText`, `TStyleTextObject` | Self | Цвет рамки строк. Через GetColorFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4558](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4558>) |
| `glow` | `TColorObject или TText` | `TColorObject`, `TText`, `TStyleTextObject` | Self | Цвет эффекта растяжения при прокрутке. Через GetColorFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4613](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4613>) |
| `header` | `TStyleObject` | `TStyleObject` | Self | Изображение заголовка строки. Через GetStyleObjectFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4581](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4581>) |
| `headerfont` | `TFontObject или TText` | `TFontObject`, `TText`, `TStyleTextObject` | Self | Шрифт заголовка. Через AssignFontFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4575](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4575>) |
| `headertext` | `TColorObject или TText` | `TColorObject`, `TText`, `TStyleTextObject` | Self | Цвет текста заголовка. Через GetColorFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4564](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4564>) |
| `headertextshadow` | `TColorObject или TText` | `TColorObject`, `TText`, `TStyleTextObject` | Self | Цвет тени заголовка. Через GetColorFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4565](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4565>) |
| `indicator` | `TColorObject или TText` | `TColorObject`, `TText`, `TStyleTextObject` | Self | Цвет индикатора обновления. Через GetColorFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4614](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4614>) |
| `itembackground` | `TColorObject или TText` | `TColorObject`, `TText`, `TStyleTextObject` | Self | Цвет фона строки. Через GetColorFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4556](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4556>) |
| `pullrefreshstroke` | `TColorObject или TText` | `TColorObject`, `TText`, `TStyleTextObject` | Self | Цвет линии pull-to-refresh. Через GetColorFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4615](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4615>) |
| `selection` | `TColorObject или TText` | `TColorObject`, `TText`, `TStyleTextObject` | Self | Сначала изображение TStyleObject, при отсутствии — цвет выделения. Через GetColorFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4580](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4580>) |
| `selection` | `TStyleObject` | `TStyleObject` | Self | Сначала изображение TStyleObject, при отсутствии — цвет выделения. Через GetStyleObjectFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4580](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4580>) |
| `selectiontext` | `TColorObject или TText` | `TColorObject`, `TText`, `TStyleTextObject` | Self | Цвет выбранного текста. Через GetColorFromStyle. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4562](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4562>) |
| `touchanimation` | `TCustomStyleObject + ITouchAnimationObject для анимации` | `TActiveStyleObject` | Self | Анимация касания. | `TListViewBase.ApplyStyle`<br>[FMX.ListView.pas:4584](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ListView.pas:4584>) |

### TMenuBar

Горизонтальная строка меню. Предок: `TStyledControl`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `content` | `TControl` | `TLayout`, `TRectangle` | Self | Контейнер/область содержимого. | `TMenuBar.ApplyStyle`<br>[FMX.Menus.pas:2873](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Menus.pas:2873>) |

### TMenuItem

Пункт меню с текстом, отметкой, глифом, shortcut и указателем подменю. Предок: `TTextControl`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `bitmap` | `TControl` | `TImage`, `TGlyph` | Self | Область bitmap пункта. | `TMenuItem.ApplyStyle`<br>[FMX.Menus.pas:1532](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Menus.pas:1532>) |
| `checkbackground` | `TControl` | `TLayout`, `TRectangle` | Self | Фон отметки меню. | `TMenuItem.ApplyStyle`<br>[FMX.Menus.pas:1530](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Menus.pas:1530>) |
| `checkmark` | `TControl` | `TPath`, `TButton` | Self | Отметка выбранного пункта. | `TMenuItem.ApplyStyle`<br>[FMX.Menus.pas:1524](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Menus.pas:1524>) |
| `checkmarkstyle` | `TControl` | `TPath`, `TButton` | Self | Альтернативная отметка меню. | `TMenuItem.ApplyStyle`<br>[FMX.Menus.pas:1539](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Menus.pas:1539>) |
| `glyph` | `TControl` | `TImage`, `TGlyph` | Self | Область глифа меню. | `TMenuItem.ApplyStyle`<br>[FMX.Menus.pas:1513](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Menus.pas:1513>) |
| `glyphstyle` | `TGlyph` | `TGlyph`, `TTintedGlyph` | Self | Глиф, связанный с Images/ImageIndex. | `TMenuItem.ApplyStyle`<br>[FMX.Menus.pas:1518](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Menus.pas:1518>) |
| `height` | `TStyleTag` | `TStyleTag` | Self | Тег высоты пункта. | `TMenuItem.ApplyStyle`<br>[FMX.Menus.pas:1550](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Menus.pas:1550>) |
| `shortcut` | `TText` | `TText` | Self | Текст сочетания клавиш. | `TMenuItem.ApplyStyle`<br>[FMX.Menus.pas:1542](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Menus.pas:1542>) |
| `submark` | `TControl` | `TPath`, `TButton` | Self | Указатель подменю. | `TMenuItem.ApplyStyle`<br>[FMX.Menus.pas:1545](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Menus.pas:1545>) |

### TMenuView

Визуальный контейнер пунктов меню. Предок: `TStyledControl`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `content` | `TControl` | `TLayout`, `TRectangle` | Self | Контейнер/область содержимого. | `TMenuView.ApplyStyle`<br>[FMX.Menus.pas:2296](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Menus.pas:2296>) |

### TMultiViewBaseBorderedPresentation

Представление MultiView с бордюром. Предок: `TMultiViewPresentation`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `dropline` | `TBrushObject` | `TBrushObject` | Self (MultiView) | Кисть разделительной линии MultiView. | `TMultiViewBaseBorderedPresentation.UpdateStyle`<br>[FMX.MultiView.Presentations.pas:1433](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.MultiView.Presentations.pas:1433>) |

### TPathLabel

Подпись вдоль пути, использующая параметры TText. Предок: `TStyledControl`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `text` | `TText` | `TText` | Self | Текст и параметры подписи. | `TPathLabel.ApplyStyle`<br>[FMX.StdCtrls.pas:8916](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:8916>) |

### TPopup

Всплывающий контейнер с оформляемым фоном. Предок: `TStyledControl`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `background` | `TControl` | `TRectangle`, `TStyleObject` | Self | Фон контрола. | `TPopup.ApplyStyle`<br>[FMX.Controls.pas:8674](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Controls.pas:8674>) |

### TPopupCell

Редактор выбора из списка в ячейке. Предок: `TPopupBox`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `content` | `TControl` | `TLayout`, `TRectangle` | Self | Контейнер/область содержимого. | `TPopupCell.ApplyStyle`<br>[FMX.Grid.Style.pas:1156](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:1156>) |
| `text` | `TControl` | `TText`, `TLabel` | Self | Текст и параметры подписи. | `TPopupCell.ApplyStyle`<br>[FMX.Grid.Style.pas:1155](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:1155>) |

### TPresentedTextControl

База текстовых контролов с поддержкой presentation. Предок: `TPresentedControl`.

Повторяет текстовый контракт TTextControl в другой ветке наследования. Отсюда кнопка получает text и foreground.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `foreground` | `TBrushObject` | `TBrushObject` | Self | Цвет текста из кисти. | `TPresentedTextControl.ApplyStyle`<br>[FMX.StdCtrls.pas:3042](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:3042>) |
| `text` | `TControl; ITextSettings для настроек; TText/ICaption для текста; IObjectState необязателен` | `TText`, `TStyleTextObject`, `TLabel` | Self | Текст и параметры подписи. | `TPresentedTextControl.FindTextObject`<br>[FMX.StdCtrls.pas:2985](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:2985>) |

### TProgressBar

Индикатор прогресса с выбором ориентации. Предок: `TPresentedControl`.

hindicator/vindicator ищутся через переменную IndicatorStyleName в ApplyStyle и при выравнивании. Имена по разным ориентациям не требуются одновременно.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `hindicator` | `TFmxObject (без ограничения подкласса в этом чтении)` | `TLayout`, `TStyleObject` | Self | Горизонтальный индикатор прогресса. По Orientation; запуск триггера IsVisible. | `TProgressBar.ApplyStyle`<br>[FMX.StdCtrls.pas:5817](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:5817>) |
| `hindicator` | `TControl` | `TLayout`, `TRectangle` | Self | Горизонтальный индикатор прогресса. | `TProgressBar.DoRealign`<br>[FMX.StdCtrls.pas:5891](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:5891>) |
| `htrack` | `TControl` | `TLayout`, `TRectangle` | Self | Горизонтальный трек. | `TProgressBar.DoRealign`<br>[FMX.StdCtrls.pas:5874](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:5874>) |
| `htrack` | `TControl` | `TLayout`, `TRectangle` | Self | Горизонтальный трек. | `TProgressBar.DoRealign`<br>[FMX.StdCtrls.pas:5878](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:5878>) |
| `track` | `TControl` | `TLayout`, `TRectangle` | Self | Общий/запасной вариант трека. | `TProgressBar.DoRealign`<br>[FMX.StdCtrls.pas:5884](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:5884>) |
| `vindicator` | `TFmxObject (без ограничения подкласса в этом чтении)` | `TLayout`, `TStyleObject` | Self | Вертикальный индикатор прогресса. По Orientation; запуск триггера IsVisible. | `TProgressBar.ApplyStyle`<br>[FMX.StdCtrls.pas:5819](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:5819>) |
| `vindicator` | `TControl` | `TLayout`, `TRectangle` | Self | Вертикальный индикатор прогресса. | `TProgressBar.DoRealign`<br>[FMX.StdCtrls.pas:5893](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:5893>) |
| `vtrack` | `TControl` | `TLayout`, `TRectangle` | Self | Вертикальный трек. | `TProgressBar.DoRealign`<br>[FMX.StdCtrls.pas:5872](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:5872>) |

### TProgressCell

Индикатор прогресса в ячейке. Предок: `TProgressBar`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `hindicator` | `TFmxObject + IDrawableObject` | `TStyleObject`, `TStyleTextObject` | Self | Горизонтальный индикатор прогресса. | `TProgressCell.ApplyStyle`<br>[FMX.Grid.Style.pas:633](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:633>) |
| `htrack` | `TFmxObject + IDrawableObject` | `TStyleObject`, `TStyleTextObject` | Self | Горизонтальный трек. | `TProgressCell.ApplyStyle`<br>[FMX.Grid.Style.pas:634](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:634>) |
| `track` | `TFmxObject + IDrawableObject` | `TStyleObject`, `TStyleTextObject` | Self | Общий/запасной вариант трека. | `TProgressCell.ApplyStyle`<br>[FMX.Grid.Style.pas:635](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:635>) |

### TScrollBar

Полоса прокрутки с треком и кнопками направлений. Предок: `TStyledControl`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `bottombutton` | `TCustomButton` | `TButton`, `TSpeedButton` | Self | Прокрутка вниз. | `TScrollBar.ApplyStyle`<br>[FMX.StdCtrls.pas:7628](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:7628>) |
| `htrack` | `TCustomTrack` | `TTrack`, `TTrackBar` | Self | Горизонтальный трек. | `TScrollBar.ApplyStyle`<br>[FMX.StdCtrls.pas:7565](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:7565>) |
| `leftbutton` | `TCustomButton` | `TButton`, `TSpeedButton` | Self | Прокрутка влево. | `TScrollBar.ApplyStyle`<br>[FMX.StdCtrls.pas:7597](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:7597>) |
| `rightbutton` | `TCustomButton` | `TButton`, `TSpeedButton` | Self | Прокрутка вправо. | `TScrollBar.ApplyStyle`<br>[FMX.StdCtrls.pas:7620](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:7620>) |
| `topbutton` | `TCustomButton` | `TButton`, `TSpeedButton` | Self | Прокрутка вверх. | `TScrollBar.ApplyStyle`<br>[FMX.StdCtrls.pas:7605](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:7605>) |
| `track` | `TCustomTrack` | `TTrack`, `TTrackBar` | Self | Общий/запасной вариант трека. | `TScrollBar.ApplyStyle`<br>[FMX.StdCtrls.pas:7565](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:7565>) |
| `vtrack` | `TCustomTrack` | `TTrack`, `TTrackBar` | Self | Вертикальный трек. | `TScrollBar.ApplyStyle`<br>[FMX.StdCtrls.pas:7579](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:7579>) |

### TSelectionPoint

Маркер текстового выделения/каретки. Предок: `TStyledControl`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `Background` | `TControl` | `TRectangle`, `TStyleObject` | Self | Фон контрола. | `TSelectionPoint.ApplyStyle`<br>[FMX.Objects.pas:4257](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Objects.pas:4257>) |

### TSkLabel

Текстовая подпись Skia с настройками от корня или объекта text. Предок: `TSkStyledControl`.

Если ResourceLink поддерживает ISkStyleTextObject, используется сам корень. Иначе ищется text. Настройки извлекаются через интерфейсы; наличие имени не гарантирует соответствие типа.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `text` | `TFmxObject; ISkStyleTextObject или ITextSettings` | `TSkStyleTextObject`, `TText`, `TStyleTextObject` | Self | Текст и параметры подписи. | `TSkLabel.ApplyStyle`<br>[FMX.Skia.pas:5266](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Skia.pas:5266>) |

### TSpinEditButton

Составная кнопка редактора с upbutton/downbutton. Предок: `TStyledControl`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `downbutton` | `TCustomButton` | `TButton`, `TSpeedButton` | Self | Уменьшение значения. | `TSpinEditButton.ApplyStyle`<br>[FMX.Edit.pas:2452](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.pas:2452>) |
| `upbutton` | `TCustomButton` | `TButton`, `TSpeedButton` | Self | Увеличение значения. | `TSpinEditButton.ApplyStyle`<br>[FMX.Edit.pas:2446](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.pas:2446>) |

### TSplitter

Разделитель, изменяющий размер соседних контролов. Предок: `TStyledControl`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `grip` | `TControl` | `TLayout`, `TRectangle` | Self | Основная ручка разделителя. | `TSplitter.ApplyStyle`<br>[FMX.StdCtrls.pas:5385](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:5385>) |
| `hgrip` | `TControl` | `TLayout`, `TRectangle` | Self | Горизонтальная ручка разделителя. | `TSplitter.ApplyStyle`<br>[FMX.StdCtrls.pas:5387](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:5387>) |

### TStatusBar

Строка состояния с ручкой изменения размера. Предок: `TPresentedControl`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `sizegrip` | `TControl` | `TSizeGrip`, `TRectangle` | Self | Ручка изменения размера. | `TStatusBar.ApplyStyle`<br>[FMX.StdCtrls.pas:3662](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.StdCtrls.pas:3662>) |

### TStyledCalendar

Представление календаря с именованными частями. Предок: `TStyledPresentation`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `days` | `TListBox` | `TListBox` | Self | Список дней месяца. | `TStyledCalendar.ApplyStyle`<br>[FMX.Calendar.Style.pas:231](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Calendar.Style.pas:231>) |
| `months` | `TPopupBox` | `TPopupBox` | Self | Выбор месяца. | `TStyledCalendar.ApplyStyle`<br>[FMX.Calendar.Style.pas:179](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Calendar.Style.pas:179>) |
| `next` | `TButton` | `TButton` | Self | Следующий месяц. Через FindButtonAndAssignClickHandler. | `TStyledCalendar.ApplyStyle`<br>[FMX.Calendar.Style.pas:173](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Calendar.Style.pas:173>) |
| `prev` | `TButton` | `TButton` | Self | Предыдущий месяц. Через FindButtonAndAssignClickHandler. | `TStyledCalendar.ApplyStyle`<br>[FMX.Calendar.Style.pas:172](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Calendar.Style.pas:172>) |
| `today` | `TButton` | `TButton` | Self | Текущая дата. Через FindButtonAndAssignClickHandler. | `TStyledCalendar.ApplyStyle`<br>[FMX.Calendar.Style.pas:174](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Calendar.Style.pas:174>) |
| `week` | `TGridLayout` | `TGridLayout` | Self | Контейнер названий дней недели. | `TStyledCalendar.ApplyStyle`<br>[FMX.Calendar.Style.pas:208](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Calendar.Style.pas:208>) |
| `weeks` | `TGridLayout` | `TGridLayout` | Self | Контейнер номеров недель. | `TStyledCalendar.ApplyStyle`<br>[FMX.Calendar.Style.pas:260](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Calendar.Style.pas:260>) |
| `years` | `TPopupBox` | `TPopupBox` | Self | Выбор года. | `TStyledCalendar.ApplyStyle`<br>[FMX.Calendar.Style.pas:195](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Calendar.Style.pas:195>) |

### TStyledComboEdit

Представление ComboEdit с дополнительным расчётом popup. Предок: `TStyledComboEditBase`.

Content используется в RecalculatePopupSize вне ApplyStyle. Наследует arrow от TStyledComboEditBase и все части нового TStyledEdit.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `Content` | `TControl` | `TLayout`, `TRectangle` | Self | Контейнер/область содержимого. | `TStyledComboEdit.RecalculatePopupSize`<br>[FMX.ComboEdit.Style.pas:811](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ComboEdit.Style.pas:811>) |

### TStyledComboEditBase

Базовое представление ввода со стрелкой раскрытия. Предок: `TStyledEdit`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `arrow` | `TControl` | `TPath`, `TButton` | Self | Раскрытие всплывающего выбора. | `TStyledComboEditBase.ApplyStyle`<br>[FMX.ComboEdit.Style.pas:279](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ComboEdit.Style.pas:279>) |

### TStyledComboTrackBar

Представление редактора со всплывающим ползунком. Предок: `TStyledEditBox`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `arrow` | `TControl` | `TPath`, `TButton` | Self | Раскрытие всплывающего выбора. | `TStyledComboTrackBar.ApplyStyle`<br>[FMX.ComboTrackBar.Style.pas:209](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ComboTrackBar.Style.pas:209>) |

### TStyledCustomScrollBox

Представление контейнера прокрутки. Предок: `TStyledPresentation`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `background` | `TControl` | `TRectangle`, `TStyleObject` | Self | Фон контрола. | `TStyledCustomScrollBox.ApplyStyle`<br>[FMX.ScrollBox.Style.pas:715](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ScrollBox.Style.pas:715>) |
| `content` | `TControl` | `TLayout`, `TRectangle` | Self | Контейнер/область содержимого. | `TStyledCustomScrollBox.ApplyStyle`<br>[FMX.ScrollBox.Style.pas:745](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ScrollBox.Style.pas:745>) |
| `hscrollbar` | `TScrollBar` | `TScrollBar`, `TSmallScrollBar` | Self | Обычная горизонтальная полоса. Имя передаётся локальной процедуре; варианты осей и компактного оформления. | `TStyledCustomScrollBox.ApplyStyle`<br>[FMX.ScrollBox.Style.pas:719](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ScrollBox.Style.pas:719>) |
| `hscrollbar` | `TScrollBar` | `TScrollBar`, `TSmallScrollBar` | Self | Обычная горизонтальная полоса. Имя передаётся локальной процедуре; варианты осей и компактного оформления. | `TStyledCustomScrollBox.ReloadScrollBars`<br>[FMX.ScrollBox.Style.pas:1231](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ScrollBox.Style.pas:1231>) |
| `hsmallscrollbar` | `TScrollBar` | `TScrollBar`, `TSmallScrollBar` | Self | Компактная горизонтальная полоса. Имя передаётся локальной процедуре; варианты осей и компактного оформления. | `TStyledCustomScrollBox.ApplyStyle`<br>[FMX.ScrollBox.Style.pas:721](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ScrollBox.Style.pas:721>) |
| `hsmallscrollbar` | `TScrollBar` | `TScrollBar`, `TSmallScrollBar` | Self | Компактная горизонтальная полоса. Имя передаётся локальной процедуре; варианты осей и компактного оформления. | `TStyledCustomScrollBox.ReloadScrollBars`<br>[FMX.ScrollBox.Style.pas:1226](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ScrollBox.Style.pas:1226>) |
| `sizegrip` | `TControl` | `TSizeGrip`, `TRectangle` | Self | Ручка изменения размера. | `TStyledCustomScrollBox.ApplyStyle`<br>[FMX.ScrollBox.Style.pas:725](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ScrollBox.Style.pas:725>) |
| `vscrollbar` | `TScrollBar` | `TScrollBar`, `TSmallScrollBar` | Self | Обычная вертикальная полоса. Имя передаётся локальной процедуре; варианты осей и компактного оформления. | `TStyledCustomScrollBox.ApplyStyle`<br>[FMX.ScrollBox.Style.pas:718](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ScrollBox.Style.pas:718>) |
| `vscrollbar` | `TScrollBar` | `TScrollBar`, `TSmallScrollBar` | Self | Обычная вертикальная полоса. Имя передаётся локальной процедуре; варианты осей и компактного оформления. | `TStyledCustomScrollBox.ReloadScrollBars`<br>[FMX.ScrollBox.Style.pas:1230](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ScrollBox.Style.pas:1230>) |
| `vsmallscrollbar` | `TScrollBar` | `TScrollBar`, `TSmallScrollBar` | Self | Компактная вертикальная полоса. Имя передаётся локальной процедуре; варианты осей и компактного оформления. | `TStyledCustomScrollBox.ApplyStyle`<br>[FMX.ScrollBox.Style.pas:720](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ScrollBox.Style.pas:720>) |
| `vsmallscrollbar` | `TScrollBar` | `TScrollBar`, `TSmallScrollBar` | Self | Компактная вертикальная полоса. Имя передаётся локальной процедуре; варианты осей и компактного оформления. | `TStyledCustomScrollBox.ReloadScrollBars`<br>[FMX.ScrollBox.Style.pas:1225](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.ScrollBox.Style.pas:1225>) |

### TStyledEdit

Новое представление однострочного редактора из FMX.Edit.Style.New. Предок: `TStyledPresentation`.

В этой поставке подключён FMX.Edit.Style.New. Вводимый текст рисует редактор в содержимом; отдельный text не ищется. Маркеры выделения находит TInteractiveTextSelectors.ApplyStyle, вызываемый здесь. UpdatePopupMenuItems работает в созданном меню, не внутри editstyle.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `buttons` | `TControl` | `TLayout`, `TRectangle` | Self | Контейнер кнопок справа. | `TStyledEdit.ApplyStyle`<br>[FMX.Edit.Style.New.pas:1060](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.Style.New.pas:1060>) |
| `caretcolor` | `TColorObject` | `TColorObject` | Self | Цвет каретки. | `TStyledEdit.ApplyStyle`<br>[FMX.Edit.Style.New.pas:1100](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.Style.New.pas:1100>) |
| `content` | `TControl` | `TLayout`, `TRectangle` | Self | Контейнер/область содержимого. | `TStyledEdit.ApplyStyle`<br>[FMX.Edit.Style.New.pas:1078](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.Style.New.pas:1078>) |
| `font` | `TFmxObject + IFontObject` | `TFontObject` | Self | Шрифт текста. | `TStyledEdit.ApplyStyle`<br>[FMX.Edit.Style.New.pas:1094](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.Style.New.pas:1094>) |
| `foreground` | `TBrushObject` | `TBrushObject` | Self | Цвет текста из кисти. | `TStyledEdit.ApplyStyle`<br>[FMX.Edit.Style.New.pas:1092](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.Style.New.pas:1092>) |
| `leftbuttons` | `TControl` | `TLayout`, `TRectangle` | Self | Контейнер кнопок слева. | `TStyledEdit.ApplyStyle`<br>[FMX.Edit.Style.New.pas:1063](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.Style.New.pas:1063>) |
| `prompt` | `TControl; ICaption для текста prompt, если доступен` | `TText`, `TLabel` | Self | Подсказка пустого редактора. | `TStyledEdit.ApplyStyle`<br>[FMX.Edit.Style.New.pas:1069](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.Style.New.pas:1069>) |
| `selection` | `TBrushObject` | `TBrushObject` | Self | Оформление выделения. | `TStyledEdit.ApplyStyle`<br>[FMX.Edit.Style.New.pas:1085](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.Style.New.pas:1085>) |

### TStyledGrid

Представление таблицы с кистями, заголовком, фокусом и выделением. Предок: `TStyledCustomScrollBox`.

AlternatingRowBackground, LineFill, EditorLineFill, EditorBackground передаются массивом в LoadBrushes. Наследуется контракт TStyledCustomScrollBox. Контролы ячеек и временный checkbox имеют отдельные стили.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `AlternatingRowBackground` | `TBrushObject` | `TBrushObject` | Self | Кисть чередующихся строк. Через LoadBrushes и константы Str*. | `TStyledGrid.ApplyStyle`<br>[FMX.Grid.Style.pas:2103](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:2103>) |
| `EditorBackground` | `TBrushObject` | `TBrushObject` | Self | Кисть фона редактора ячейки. Через LoadBrushes и константы Str*. | `TStyledGrid.ApplyStyle`<br>[FMX.Grid.Style.pas:2103](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:2103>) |
| `EditorLineFill` | `TBrushObject` | `TBrushObject` | Self | Кисть рамки редактора ячейки. Через LoadBrushes и константы Str*. | `TStyledGrid.ApplyStyle`<br>[FMX.Grid.Style.pas:2103](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:2103>) |
| `focus` | `TControl` | `TRectangle`, `TStyleObject` | Self | Рамка фокуса ячейки. | `TStyledGrid.ApplyStyle`<br>[FMX.Grid.Style.pas:2125](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:2125>) |
| `header` | `THeader` | `THeader` | Self | Область/контрол заголовка. | `TStyledGrid.ApplyStyle`<br>[FMX.Grid.Style.pas:2117](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:2117>) |
| `LineFill` | `TBrushObject` | `TBrushObject` | Self | Кисть линий таблицы. Через LoadBrushes и константы Str*. | `TStyledGrid.ApplyStyle`<br>[FMX.Grid.Style.pas:2103](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:2103>) |
| `selection` | `TControl` | `TRectangle`, `TStyleObject` | Self | Оформление выделения. | `TStyledGrid.ApplyStyle`<br>[FMX.Grid.Style.pas:2127](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:2127>) |

### TStyledMemo

Новое представление многострочного редактора из FMX.Memo.Style.New. Предок: `TStyledCustomScrollBox`.

Используется FMX.Memo.Style.New. content/background/полосы/sizegrip приходят от TStyledCustomScrollBox; prompt и текстовые кисти добавляются здесь. Маркеры ищет TInteractiveTextSelectors. Команды popup-меню не являются частями memostyle.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `caretcolor` | `TColorObject` | `TColorObject` | Self | Цвет каретки. | `TStyledMemo.ApplyStyle`<br>[FMX.Memo.Style.New.pas:1131](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Memo.Style.New.pas:1131>) |
| `font` | `TFmxObject + IFontObject` | `TFontObject` | Self | Шрифт текста. | `TStyledMemo.ApplyStyle`<br>[FMX.Memo.Style.New.pas:1125](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Memo.Style.New.pas:1125>) |
| `foreground` | `TBrushObject` | `TBrushObject` | Self | Цвет текста из кисти. | `TStyledMemo.ApplyStyle`<br>[FMX.Memo.Style.New.pas:1123](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Memo.Style.New.pas:1123>) |
| `prompt` | `TControl; ICaption для текста prompt, если доступен` | `TText`, `TLabel` | Self | Подсказка пустого редактора. | `TStyledMemo.ApplyStyle`<br>[FMX.Memo.Style.New.pas:1108](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Memo.Style.New.pas:1108>) |
| `selection` | `TBrushObject` | `TBrushObject` | Self | Оформление выделения. | `TStyledMemo.ApplyStyle`<br>[FMX.Memo.Style.New.pas:1116](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Memo.Style.New.pas:1116>) |

### TStyledSearchBox

Представление строки поиска. Предок: `TStyledEdit`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `clearbutton` | `TEditButton` | `TEditButton` | Self | Очистка значения. | `TStyledSearchBox.ApplyStyle`<br>[FMX.SearchBox.Style.pas:70](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.SearchBox.Style.pas:70>) |
| `magglass` | `TEditButton` | `TEditButton` | Self | Кнопка поиска/лупа. | `TStyledSearchBox.ApplyStyle`<br>[FMX.SearchBox.Style.pas:68](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.SearchBox.Style.pas:68>) |

### TStyledSpinBox

Числовое представление с кнопками минус/плюс. Предок: `TStyledEditBox`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `minusbutton` | `TCustomButton` | `TButton`, `TSpeedButton` | Self | Уменьшение значения. | `TStyledSpinBox.ApplyStyle`<br>[FMX.SpinBox.Style.pas:56](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.SpinBox.Style.pas:56>) |
| `plusbutton` | `TCustomButton` | `TButton`, `TSpeedButton` | Self | Увеличение значения. | `TStyledSpinBox.ApplyStyle`<br>[FMX.SpinBox.Style.pas:62](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.SpinBox.Style.pas:62>) |

### TTabControl

Контейнер вкладок с параметрами высоты и фона перехода. Предок: `TStyledControl`.

FullSize используется как маркер присутствия объекта (TFmxObject). TabHeight читает TagFloat у TFmxObject; это не высота TControl.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `background` | `TControl` | `TRectangle`, `TStyleObject` | Self | Фон контрола. | `TTabControl.ApplyStyle`<br>[FMX.TabControl.pas:2267](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.TabControl.pas:2267>) |
| `FullSize` | `TFmxObject; проверяется только наличие` | `TStyleTag`, `TLayout` | Self | Маркер полного размера вкладок. | `TTabControl.ApplyStyle`<br>[FMX.TabControl.pas:2268](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.TabControl.pas:2268>) |
| `scrollbackground` | `TBrushObject` | `TBrushObject` | Self | Кисть фона перехода вкладок. | `TTabControl.ApplyStyle`<br>[FMX.TabControl.pas:2266](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.TabControl.pas:2266>) |
| `TabHeight` | `TFmxObject; числовой TagFloat` | `TStyleTag` | Self | Высота вкладок из TagFloat. | `TTabControl.ApplyStyle`<br>[FMX.TabControl.pas:2271](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.TabControl.pas:2271>) |

### TTabItem

Вкладка с вариантами top/bottom, текстом и изображением. Предок: `TTextControl`.

top/bottom — ветви внутри ResourceLink. icon/glyphstyle/layoutstyle/text ищутся в активном FItemStyle. Переопределённый FindTextObject вызывает inherited при отсутствии FItemStyle. foreground остаётся поиском по собственному стилю.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `bottom` | `TControl` | `TLayout`, `TRectangle` | Self | Нижнее оформление вкладки. | `TTabItem.ApplyStyle`<br>[FMX.TabControl.pas:982](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.TabControl.pas:982>) |
| `glyphstyle` | `TGlyph` | `TGlyph`, `TTintedGlyph` | активная ветвь top/bottom или корень | Глиф, связанный с Images/ImageIndex. | `TTabItem.ApplyStyle`<br>[FMX.TabControl.pas:1018](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.TabControl.pas:1018>) |
| `icon` | `TControl; IMultiResBitmapObject для bitmap` | `TImage` | активная ветвь top/bottom или корень | Изображение/иконка. | `TTabItem.ApplyStyle`<br>[FMX.TabControl.pas:1009](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.TabControl.pas:1009>) |
| `layoutstyle` | `TControl` | `TLayout`, `TRectangle` | активная ветвь top/bottom или корень | Контейнер компоновки вкладки. | `TTabItem.ApplyStyle`<br>[FMX.TabControl.pas:1031](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.TabControl.pas:1031>) |
| `text` | `TControl; ITextSettings для настроек; TText/ICaption для текста; IObjectState необязателен` | `TText`, `TStyleTextObject`, `TLabel` | активная ветвь top/bottom или корень | Текст и параметры подписи. | `TTabItem.FindTextObject`<br>[FMX.TabControl.pas:1059](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.TabControl.pas:1059>) |
| `top` | `TControl` | `TLayout`, `TRectangle` | Self | Верхнее оформление вкладки. | `TTabItem.ApplyStyle`<br>[FMX.TabControl.pas:977](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.TabControl.pas:977>) |

### TTextControl

База текстовых styled контролов. Предок: `TStyledControl`.

ApplyStyle вызывает виртуальный FindTextObject, где ищется `text`. Для настроек используются ITextSettings/IObjectState; ресурс не обязан буквально быть TText.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `foreground` | `TBrushObject` | `TBrushObject` | Self | Цвет текста из кисти. | `TTextControl.ApplyStyle`<br>[FMX.Controls.pas:7716](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Controls.pas:7716>) |
| `text` | `TControl; ITextSettings для настроек; TText/ICaption для текста; IObjectState необязателен` | `TText`, `TStyleTextObject`, `TLabel` | Self | Текст и параметры подписи. | `TTextControl.FindTextObject`<br>[FMX.Controls.pas:7657](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Controls.pas:7657>) |

### TTimeCell

Редактор времени в ячейке. Предок: `TCustomTimeEdit`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `background` | `TControl` | `TRectangle`, `TStyleObject` | Self | Фон контрола. | `TTimeCell.ApplyStyle`<br>[FMX.Grid.Style.pas:1055](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:1055>) |
| `content` | `TControl` | `TLayout`, `TRectangle` | Self | Контейнер/область содержимого. | `TTimeCell.ApplyStyle`<br>[FMX.Grid.Style.pas:1050](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:1050>) |
| `text` | `TControl` | `TText`, `TLabel` | Self | Текст и параметры подписи. | `TTimeCell.ApplyStyle`<br>[FMX.Grid.Style.pas:1049](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.Style.pas:1049>) |

### TTreeViewItem

Узел дерева с текстом, раскрытием, флажком и глифом. Предок: `TTextControl`.

| StyleName | Проверяемый тип / условие | Возможные классы | Область поиска | Назначение | Метод и источник |
| --- | --- | --- | --- | --- | --- |
| `button` | `TCustomButton` | `TButton`, `TSpeedButton` | Self | Кнопка действия/раскрытия. | `TTreeViewItem.ApplyStyle`<br>[FMX.TreeView.pas:1001](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.TreeView.pas:1001>) |
| `check` | `TCheckBox` | `TCheckBox` | Self | Встроенный флажок. | `TTreeViewItem.ApplyStyle`<br>[FMX.TreeView.pas:1011](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.TreeView.pas:1011>) |
| `expander` | `TControl` | `TPath`, `TButton` | Self | Область раскрытия узла. | `TTreeViewItem.ApplyStyle`<br>[FMX.TreeView.pas:1000](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.TreeView.pas:1000>) |
| `glyphstyle` | `TGlyph` | `TGlyph`, `TTintedGlyph` | Self | Глиф, связанный с Images/ImageIndex. | `TTreeViewItem.ApplyStyle`<br>[FMX.TreeView.pas:1021](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.TreeView.pas:1021>) |

## Вспомогательные ресурсы и обращения вне основного стиля

### Контекстное меню текстовых редакторов

Новые TStyledEdit/TStyledMemo создают popup-меню с элементами `undo`, `redo`, `cut`, `copy`, `paste`, `delete`, `selectall`. UpdatePopupMenuItems находит эти TMenuItem для изменения Enabled. Это StyleName созданных объектов меню, **не части editstyle/memostyle**. Меню создаётся программно.

- `TStyledEdit.UpdatePopupMenuItems`: [FMX.Edit.Style.New.pas:1261](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.Style.New.pas:1261>).
- `TStyledMemo.UpdatePopupMenuItems`: [FMX.Memo.Style.New.pas:1275](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Memo.Style.New.pas:1275>).

### Флажок в таблице

TCheckColumn.CreateBitmap получает изображения из стиля временного флажка/checkcellstyle. `checkboxunchecked`/`checkboxchecked` требуют IDrawableObject и IAlignableObject. Для старых стилей пробует `checkmark` как TPath, затем `background` как TControl; TCheckStyleObject обрабатывается отдельно. Эти запросы выполняет колонка, а не обычный TCheckBox.ApplyStyle.

| Имя | Проверяемый тип / условие | Возможные классы | Источник |
| --- | --- | --- | --- |
| `checkmark` | `TPath` | `TPath` | [FMX.Grid.pas:2387](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.pas:2387>) |
| `background` | `TControl` | `TRectangle`, `TStyleObject` | [FMX.Grid.pas:2398](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.pas:2398>) |
| `checkboxunchecked` | `TFmxObject + IDrawableObject + IAlignableObject` | `TStyleObject`, `TCheckStyleObject`, `TStyleTextObject` | [FMX.Grid.pas:2359](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.pas:2359>) |
| `checkboxchecked` | `TFmxObject + IDrawableObject + IAlignableObject` | `TStyleObject`, `TCheckStyleObject`, `TStyleTextObject` | [FMX.Grid.pas:2359](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Grid.pas:2359>) |

### Оконная рамка

TStyledWindowBorder использует отдельный ресурс окна через FResourceLink. Все перечисленные объекты приводятся к TControl. TWinWindowBorder добавляет left/right/bottom; остальные обращения унаследованы.

| Реализация / элемент | Проверяемый класс | Возможные классы | Метод |
| --- | --- | --- | --- |
| `TStyledWindowBorder / client` | `TControl (прямое приведение)` | `TLayout`, `TRectangle` | [FMX.Forms.Border.pas:259](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Forms.Border.pas:259>) |
| `TStyledWindowBorder / caption` | `TControl (прямое приведение)` | `TLayout`, `TRectangle` | [FMX.Forms.Border.pas:260](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Forms.Border.pas:260>) |
| `TStyledWindowBorder / caption-container` | `TControl (прямое приведение)` | `TLayout`, `TRectangle` | [FMX.Forms.Border.pas:261](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Forms.Border.pas:261>) |
| `TStyledWindowBorder / title` | `TControl (прямое приведение)` | `TText`, `TLabel` | [FMX.Forms.Border.pas:262](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Forms.Border.pas:262>) |
| `TStyledWindowBorder / close` | `TControl (прямое приведение)` | `TButton`, `TSpeedButton` | [FMX.Forms.Border.pas:263](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Forms.Border.pas:263>) |
| `TStyledWindowBorder / max` | `TControl (прямое приведение)` | `TButton`, `TSpeedButton` | [FMX.Forms.Border.pas:269](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Forms.Border.pas:269>) |
| `TStyledWindowBorder / min` | `TControl (прямое приведение)` | `TButton`, `TSpeedButton` | [FMX.Forms.Border.pas:275](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Forms.Border.pas:275>) |
| `TStyledWindowBorder / Res` | `TControl (прямое приведение)` | `TButton`, `TSpeedButton` | [FMX.Forms.Border.pas:299](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Forms.Border.pas:299>) |
| `TStyledWindowBorder / icon` | `TControl (прямое приведение)` | `TImage`, `TGlyph` | [FMX.Forms.Border.pas:305](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Forms.Border.pas:305>) |
| `TStyledWindowBorder / mask` | `TControl (прямое приведение)` | `TLayout`, `TRectangle` | [FMX.Forms.Border.pas:306](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Forms.Border.pas:306>) |
| `TWinWindowBorder / left` | `TControl (прямое приведение)` | `TLayout`, `TRectangle` | [FMX.Forms.Border.Win.pas:1591](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Forms.Border.Win.pas:1591>) |
| `TWinWindowBorder / right` | `TControl (прямое приведение)` | `TLayout`, `TRectangle` | [FMX.Forms.Border.Win.pas:1592](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Forms.Border.Win.pas:1592>) |
| `TWinWindowBorder / bottom` | `TControl (прямое приведение)` | `TLayout`, `TRectangle` | [FMX.Forms.Border.Win.pas:1593](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Forms.Border.Win.pas:1593>) |

### Платформенные текстовые представления

При ControlType=Platform фактическое оформление определяется native presentation. Нельзя автоматически требовать от него весь контракт styled редактора. В исходниках найдены следующие отдельные именованные чтения:

| Реализация / элемент | Проверяемый тип | Возможные классы | Где читается |
| --- | --- | --- | --- |
| `TAndroidNativeEdit / font` | `TFmxObject + IFontObject` | `TFontObject` | [PMApplyStyleLookup](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.Android.pas:376>) |
| `TiOSThemedNativeEdit / font` | `TFmxObject + IFontObject` | `TFontObject` | [PMApplyStyleLookup](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.iOS.pas:651>) |
| `TiOSThemedNativeEdit / foreground` | `TBrushObject` | `TBrushObject` | [PMApplyStyleLookup](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.iOS.pas:655>) |
| `TiOSThemedNativeMemo / font` | `TFmxObject + IFontObject` | `TFontObject` | [PMApplyStyleLookup](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Memo.iOS.pas:636>) |
| `TiOSThemedNativeMemo / foreground` | `TBrushObject` | `TBrushObject` | [PMApplyStyleLookup](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Memo.iOS.pas:640>) |

### Старые текстовые представления

Поставка также содержит FMX.Edit.Style.pas, FMX.Memo.Style.pas и FMX.Text.Deprecated.pas с **одноимёнными** TStyled* классами. Их нельзя объединять с новыми реализациями только по ClassName. FMX.Edit.pas и FMX.Memo.pas подключают `.Style.New`; актуальные ComboEdit/EditBox/SearchBox/MaskEdit наследуют новый редактор. Старые реализации похожи по именам, но отличаются поведением, вызовами и меню. Старый TStyledMemo не добавляет новый prompt в своём ApplyStyle.

| Старый модуль | Класс | Собственные имена и возможные/требуемые классы |
| --- | --- | --- |
| [FMX.Edit.Style.pas](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Edit.Style.pas:271>) | `TStyledEdit` | `buttons` — `TControl`<br>`caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftbuttons` — `TControl`<br>`leftselectionpoint` — `TSelectionPoint`<br>`prompt` — `TControl (ICaption)`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| [FMX.Memo.Style.pas](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Memo.Style.pas:1439>) | `TStyledMemo` | `caretcolor` — `TColorObject`<br>`caretpoint` — `TSelectionPoint`<br>`content` — `TControl`<br>`font` — `TFontObject (IFontObject)`<br>`foreground` — `TBrushObject`<br>`leftselectionpoint` — `TSelectionPoint`<br>`rightselectionpoint` — `TSelectionPoint`<br>`selection` — `TBrushObject` |
| [FMX.Text.Deprecated.pas](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Text.Deprecated.pas:409>) | `TStyledComboEditBase` | `arrow` — `TControl` |
| [FMX.Text.Deprecated.pas](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Text.Deprecated.pas:1187>) | `TStyledComboTrackBar` | `arrow` — `TControl` |
| [FMX.Text.Deprecated.pas](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Text.Deprecated.pas:1504>) | `TStyledSearchBox` | `clearbutton` — `TEditButton`<br>`magglass` — `TEditButton` |
| [FMX.Text.Deprecated.pas](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Text.Deprecated.pas:1528>) | `TStyledSpinBox` | `minusbutton` — `TCustomButton`<br>`plusbutton` — `TCustomButton` |

## Контролы без собственного поиска именованных частей

Отсутствие имён в коде не означает отсутствие оформления. TPanel, TToolBar, TSizeGrip, TThumb, THeader используют корневой ресурс, создаваемые дочерние контролы, свойства и триггеры. TCheckBox/TRadioButton наследуют text/foreground, но не ищут собственный checkmark. TSwitch зависит от типа корня TCustomSwitchObject.

TLayout, TGridLayout, TFlowLayout, TRectangle, TRoundRect, TCircle, TEllipse, TPath, TText, TImage, TPaintBox, TGlyph, TViewport3D и большинство 3D-объектов не наследуют TStyledControl. Обычно это строительные части стиля, рисующие себя, а не потребители фиксированного списка частей через ApplyStyle. Native WebBrowser/MapView/MediaPlayerControl и рекламные представления имеют другой механизм вывода и не включены в основной каталог. Служебные классы доступа вроде TOpenEdit/TOpenHeader, platform-прокси и реализации графических бэкендов не перечислены как самостоятельные пользовательские контролы.

## Динамические имена и границы анализа

Подменю редактора «Используется в ...» объединяет стандартные имена, зависимости составных контролов и ссылки из свойств объектов текущей книги. После разделителя оно перечисляет классы контролов, включая владельцев ресурсов, которые создают внутренних потребителей во время выполнения. Фиксированные ссылки из кода и условные имена встроены в `SBD.StyleCatalog.Data.inc` через `AddUsage`; они наследуются классами-потомками и не добавляют ресурсы в шаблоны автоматически.

| Ресурс / источник имени | Потребитель и связь | Исходник Delphi 13 |
| --- | --- | --- |
| `calendarlabelstyle`, `dayitemstyle` | `TCalendar` / `TStyledCalendar` создаёт подписи недель и `TDayItem`. | `FMX.Calendar.Style.pas:221,240` |
| `SourceLookup` | `TCustomStyleObject` и его потомки ищут `TImage` в книге по имени. `TMaskedImage` перенаправляет свойство внутреннему объекту стиля. Редактор учитывает эти ссылки у корневых и вложенных объектов в обоих меню связей. | `FMX.Styles.Objects.pas:1673,2762,2863` |
| `DefaultItemStyles.ItemStyle` списка `days` | Имя стиля `TDayItem` выбирается из списка календаря. В WinUI3 это `days_itemstyle`; имя не зашито в коде FMX. Связь читается из книги, даже если самих дней в ней нет. | `FMX.Calendar.Style.pas:231,240`; `FMX.ListBox.pas:1382,1397` |
| `DefaultItemStyles.GroupHeaderStyle/GroupFooterStyle` | `TListBoxGroupHeader` / `TListBoxGroupFooter` выбирают стиль из настроек списка. | `FMX.ListBox.pas:5477,5499` |
| `spinleftbutton`, `spinrightbutton` | `TTabControl` передаёт имя из массива `ButtonStyleNames` в создаваемый `TSpeedButton`. | `FMX.TabControl.pas:341,3620,3725` |
| `listitemdeletebutton` | `TListViewBase` и его потомки создают кнопку удаления строки. | `FMX.ListView.pas:2322` |
| `pushpanel` | Представление MultiView назначает стиль целевой панели при сдвиге. | `FMX.MultiView.Presentations.pas:158,1078` |
| `checkcellstyle` | `TCheckColumn` использует временный `TTmpCheckBox` для рисования ячейки. | `FMX.Grid.pas:2288,2445` |
| `HeaderSettings.StyleLookup` | Имя стиля заголовка колонки передаётся создаваемому `TGridHeaderItem`. | `FMX.Grid.Style.pas:3497` |
| `PopoverOptions.StyleLookup` | Представление MultiView передаёт имя всплывающему `TCustomPopover`. | `FMX.MultiView.Presentations.pas:312` |
| `comboeditstyle`, `magnifierglassrectanglestyle`, `listboxgroupheader`, `tabdotstyle`, `menuseparatorstyle`, `menubaritemstyle` | Условные имена `TCalendarEdit`, `TMagnifierGlass`, `TListBoxGroupHeader`, `TTabItem`, `TMenuItem`. | `FMX.CalendarEdit.pas:235`; `FMX.MagnifierGlass.pas:259`; `FMX.ListBox.pas:5443`; `FMX.TabControl.pas:1714`; локальный `FMX.Menus.pas:1681` |

Следующие обращения зависят от свойства/данных приложения. Конечный список имён нельзя получить только из исходников FMX:

| Метод | Откуда приходит имя / назначение | Источник |
| --- | --- | --- |
| `TStyledControl.RequestStyleData` | StylesData: часть перед точкой — имя объекта, остаток — путь свойства. | [FMX.Controls.pas:5828](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Controls.pas:5828>) |
| `TStyledControl.StyleDataChanged` | Запись данных в именованный объект стиля. | [FMX.Controls.pas:6506](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Controls.pas:6506>) |
| `TStyledPresentation.GetDataFromStyleObject` | Чтение именованного объекта/свойства через presentation. | [FMX.Presentation.Style.pas:324](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Presentation.Style.pas:324>) |
| `TStyledPresentation.SetDataToStyleObject` | Запись именованного объекта/свойства через presentation. | [FMX.Presentation.Style.pas:678](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Presentation.Style.pas:678>) |
| `TBrushResource.GetBrush` | StyleLookup кисти выбирает отдельный ресурс. | [FMX.Graphics.pas:2271](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Graphics.pas:2271>) |
| `TPathData.GetPath` | StyleLookup пути выбирает отдельный ресурс. | [FMX.Graphics.pas:4895](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Graphics.pas:4895>) |
| `TBitmapListAnimation.RefreshBitmap` | AnimationLookup выбирает ресурс bitmap-анимации. | [FMX.Ani.pas:2405](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Ani.pas:2405>) |
| `TCustomStyleObject.SetSourceLookup` | SourceLookup выбирает исходный ресурс объекта стиля. | [FMX.Styles.Objects.pas:1673](<G:/Program Files (x86)/Embarcadero/Studio/37.0/source/fmx/FMX.Styles.Objects.pas:1673>) |

Условиями использования частей служат platform proxy, Orientation, положение вкладки, режим выделения, наличие интерфейсов и тип ResourceLink. Набор из таблицы не означает, что все части должны существовать одновременно или что любой объект с таким StyleName подходит по типу.

При обновлении RAD Studio каталог нужно сверить с новым source/fmx: найти вызовы, раскрыть константы/массивы и локальные функции, проверить области поиска, inherited и регистрации presentation. Локальные ссылки привязаны к установленным исходникам; имена модулей и строки сохранены для проверки на другой машине.
