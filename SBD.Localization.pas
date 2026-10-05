unit SBD.Localization;

interface

uses
  System.Classes, FMX.Types, FMX.Forms;

procedure ConfigureLanguages(Language: TLang);

procedure TranslateForm(Form: TForm);

function CanonicalValueKind(const Display: string): string;

implementation

uses
  System.SysUtils, FMX.Controls, FMX.StdCtrls, FMX.Grid, FMX.ListBox, FMX.Edit;

var
  OriginalUIStrings: TStringList;

function TranslateUI(const Text: string): string;
var
  Index: Integer;
begin
  Result := Text;
  if OriginalUIStrings <> nil then
  begin
    Index := OriginalUIStrings.IndexOfName(Text);
    if Index >= 0 then
      Result := OriginalUIStrings.ValueFromIndex[Index];
  end;
  Result := Translate(Result);
end;

procedure ConfigureLanguages(Language: TLang);

  procedure Add(const Russian, English: string);
  begin
    Language.Original.Add(Russian);
    Language.LangStr['ru'].Values[Russian] := Russian;
    Language.LangStr['en-US'].Values[Russian] := English;
    OriginalUIStrings.Values[English] := Russian;
  end;

begin
  FreeAndNil(OriginalUIStrings);
  OriginalUIStrings := TStringList.Create;
  OriginalUIStrings.CaseSensitive := True;
  Language.AutoSelect := False;
  Language.AddLang('ru');
  Language.AddLang('en-US');
  Add('Тема приложения', 'App theme');
  Add('Мастер градиента', 'Gradient editor');
  Add('Настройте направление и цветовые точки. Шахматный фон показывает прозрачность.',
    'Set the direction and color stops. The checkerboard shows transparency.');
  Add('Тип градиента', 'Gradient type');
  Add('Линейный', 'Linear');
  Add('Радиальный', 'Radial');
  Add('Угол (°)', 'Angle (°)');
  Add('Угол линейного градиента', 'Linear gradient angle');
  Add('0° — вправо, 90° — вверх. Поверните диск или введите точный угол.',
    '0° points right, 90° points up. Rotate the dial or enter an exact angle.');
  Add('Центр X (%)', 'Center X (%)');
  Add('Центр Y (%)', 'Center Y (%)');
  Add('Цветовые точки', 'Color stops');
  Add('Положение (%)', 'Position (%)');
  Add('Развернуть цвета', 'Reverse colors');
  Add('Добавьте как минимум две цветовые точки', 'Add at least two color stops');
  Add('Выберите угол, чтобы задать направление градиента', 'Choose an angle to set the gradient direction');
  Add('Как в системе', 'Use system parameters');
  Add('Светлая', 'Light');
  Add('Тёмная', 'Dark');
  Add('Язык приложения', 'App language');
  Add('Параметры вида', 'View settings');
  Add('Закрыть', 'Close');
  Add('Перенос строк', 'Word wrap');
  Add('Перенос строк меняет только отображение текста', 'Word wrap only changes how text is displayed');
  Add('Не сохранять', 'Don''t save');
  Add('Полужирный', 'Bold');
  Add('Курсив', 'Italic');
  Add('Подчёркнутый', 'Underline');
  Add('Зачёркнутый', 'Strikeout');
  Add('Размер', 'Size');
  Add('Начертание', 'Style');
  Add('Семейство', 'Family');
  Add('Образец', 'Sample');
  Add('Поиск', 'Search');
  Add('Файл', 'File');
  Add('Сохранить', 'Save');
  Add('Отменить', 'Undo');
  Add('Повторить', 'Redo');
  Add('Предпросмотр', 'Preview');
  Add('Значения', 'Values');
  Add('Новый стиль', 'New style');
  Add('Открыть…', 'Open…');
  Add('Сохранить как…', 'Save as…');
  Add('Импортировать стиль системы', 'Import system style');
  Add('Вставить TStyleBook (Ctrl+Shift+V)', 'Paste TStyleBook (Ctrl+Shift+V)');
  Add('Копировать TStyleBook (Ctrl+Shift+C)', 'Copy TStyleBook (Ctrl+Shift+C)');
  Add('Копировать (Ctrl+C)', 'Copy (Ctrl+C)');
  Add('Вставить (Ctrl+V)', 'Paste (Ctrl+V)');
  Add('Сортировать стили по имени', 'Sort styles by name');
  Add('Используется в ...', 'Used in ...');
  Add('Зависимости', 'Dependencies');
  Add('Нет использующих стилей', 'No styles use this style');
  Add('Нет известных классов контролов', 'No known control classes');
  Add('Нет зависимостей', 'No dependencies');
  Add(' (стиль отсутствует в книге)', ' (style missing from book)');
  Add('Проверить стиль', 'Validate style');
  Add('Справочник стилей FMX', 'FMX style reference');
  Add('Создать шаблон', 'Create template');
  Add('Название класса', 'Class name');
  Add('Классы не найдены.', 'No classes found.');
  Add('Элемент', 'Element');
  Add('Требуемый тип / условие', 'Required type / condition');
  Add('Область поиска', 'Search scope');
  Add('Объявлен в', 'Declared in');
  Add('Возможные классы: ', 'Possible classes: ');
  Add('Источник: ', 'Source: ');
  Add('создать', 'create');
  Add('уже в дереве', 'already in tree');
  Add('Именованные элементы не запрашиваются.', 'No named elements are requested.');
  Add('Основной стиль создаётся всегда; совпадение имени добавляет индекс.',
    'The main style is always created; a duplicate name receives a numeric suffix.');
  Add('Найдите класс контрола. Шаблон содержит элементы и недостающие стили зависимостей; оформление можно настроить в редакторе.',
    'Find a control class. The template contains parts and missing dependency styles; customize its appearance in the editor.');
  Add('Создать группу', 'Create group');
  Add('Переименовать группу', 'Rename group');
  Add('Переместить в группу…', 'Move to group…');
  Add('Переместить в группу', 'Move to group');
  Add('Убрать из группы', 'Remove from group');
  Add('Дублировать', 'Duplicate');
  Add('Удалить', 'Delete');
  Add('Переместить выше', 'Move up');
  Add('Переместить ниже', 'Move down');
  Add('Вложить в предыдущий объект', 'Indent into previous object');
  Add('Вынести на уровень выше', 'Outdent');
  Add('Удалить группу, сохранив стили', 'Delete group, keep styles');
  Add('Ресурсы и объекты стиля', 'Style resources and objects');
  Add('Структура стиля', 'Style structure');
  Add('Добавить ресурс', 'Add resource');
  Add('Добавить компонент', 'Add component');
  Add('Рабочая область', 'Workspace');
  Add('Инспектор', 'Inspector');
  Add('Свойства', 'Properties');
  Add('Свойство', 'Property');
  Add('Значение', 'Value');
  Add('Именованное значение', 'Named value');
  Add('Именованные значения', 'Named values');
  Add('Ресурсы', 'Resources');
  Add('Палитра FMX', 'FMX palette');
  Add('Компоненты', 'Components');
  Add('Найти компонент', 'Find component');
  Add('Найти свойство', 'Find property');
  Add('Связать выбранное свойство со значением', 'Bind selected property to value');
  Add('Отвязать свойство, сохранив значение', 'Unbind property, keep value');
  Add('Все', 'All');
  Add('Визуальные', 'Visual');
  Add('Анимации', 'Animations');
  Add('Эффекты', 'Effects');
  Add('Рамка', 'Frame');
  Add('Направляющие', 'Guides');
  Add('Размеры', 'Dimensions');
  Add('Центрировать', 'Center');
  Add('Светлый фон', 'Light background');
  Add('Светлая тема', 'Light theme');
  Add('Тёмная тема', 'Dark theme');
  Add('Для светлой темы', 'For light theme');
  Add('Для тёмной темы', 'For dark theme');
  Add('Некорректный режим ресурсов.', 'Invalid resource theme.');
  Add('Тёмный фон', 'Dark background');
  Add('Без имени', 'Untitled');
  Add('(без имени)', '(unnamed)');
  Add('Без группы', 'No group');
  Add(' (группа)', ' (group)');
  Add('Группа: ', 'Group: ');
  Add('Новая группа', 'New group');
  Add('Группа стилей', 'Style group');
  Add('Название группы', 'Group name');
  Add('Название', 'Name');
  Add('Переместить', 'Move');
  Add('Отмена', 'Cancel');
  Add('Применить', 'Apply');
  Add('Добавить', 'Add');
  Add('Имя', 'Name');
  Add('Тип', 'Type');
  Add('Связи', 'Bindings');
  Add('Цвет', 'Color');
  Add('Число', 'Number');
  Add('Целое', 'Integer');
  Add('Текст', 'Text');
  Add('Логическое', 'Boolean');
  Add('Прозрачность', 'Transparency');
  Add('Цвет ресурса', 'Resource color');
  Add('Выберите цвет и прозрачность', 'Choose color and opacity');
  Add('Коллекция', 'Collection');
  Add('Редактор коллекции', 'Collection editor');
  Add('Редактор BitmapLinks', 'BitmapLinks editor');
  Add('Images — TImage в корне', 'Images — root TImage');
  Add('Ссылки', 'Links');
  Add('Разрешения', 'Resolutions');
  Add('Предпросмотр 9-patch', '9-patch preview');
  Add('Имя TImage в корне книги стилей', 'Root TImage style name');
  Add('Синие маркеры — SourceRect, бирюзовые — CapInsets. Шаг 1 px. Колесо — масштаб, СКМ — перемещение.',
    'Blue handles: SourceRect. Teal handles: CapInsets. Step: 1 px. Wheel: zoom. Middle mouse: pan.');
  Add('Выберите TImage из корня книги стилей или введите SourceLookup.', 'Select a root TImage or enter SourceLookup.');
  Add('Scale должен быть больше нуля.', 'Scale must be greater than zero.');
  Add('Разрешения одной ссылки должны иметь разные Scale.', 'Each resolution of a link must have a different Scale.');
  Add('SourceRect должен задавать область внутри изображения.', 'SourceRect must be inside the image.');
  Add('CapInsets не должны пересекаться или выходить за SourceRect.', 'CapInsets must not overlap or exceed SourceRect.');
  Add('Редактор коллекции ', 'Collection editor ');
  Add('Элементы коллекции', 'Collection items');
  Add('Добавляйте элементы и редактируйте их свойства', 'Add items and edit their properties');
  Add('Редактор текста', 'Text editor');
  Add('Каждая строка соответствует элементу строкового списка', 'Each line represents an item in the string list');
  Add('Шрифт', 'Font');
  Add('Предпросмотр стиля', 'Style preview');
  Add('Класс контрола…', 'Control class…');
  Add('Определять класс автоматически', 'Detect control class automatically');
  Add('Автоматически', 'Automatic');
  Add('Назначить стилю', 'Assign to style');
  Add('Классы контролов', 'Control classes');
  Add('Свойства контрола', 'Control properties');
  Add('Класс назначается только корневому стилю.', 'A control class can only be assigned to a root style.');
  Add('Некорректное назначение класса стилю.', 'Invalid style class assignment.');
  Add('Выберите класс слева. Изменяйте свойства и взаимодействуйте с контролом; назначение класса сохраняется только кнопкой «Назначить стилю».',
    'Select a class on the left. Edit properties and interact with the control; its class is saved only with Assign to style.');
  Add('Проверка TStyleBook — наведение, нажатие, фокус', 'TStyleBook preview — hover, press, focus');
  Add('Сверху — выбранный ресурс StyleLookup. Ниже — стандартные контролы с текущим StyleBook.', 'Selected StyleLookup resource above; standard controls using the current StyleBook below.');
  Add('Выберите ресурс в дереве', 'Select a resource in the tree');
  Add('Выберите ресурс в дереве или создайте новый', 'Select a resource in the tree or create one');
  Add('Контролы с обычными именами ресурсов', 'Controls using standard resource names');
  Add('Выбранный ресурс', 'Selected resource');
  Add('Текст для проверки', 'Sample text');
  Add('Включён', 'Enabled');
  Add('Отключена', 'Disabled');
  Add('Кнопка', 'Button');
  Add('Флажок', 'Check box');
  Add('Переключатель', 'Radio button');
  Add('Проверка ввода и фокуса', 'Input and focus preview');
  Add('Первый вариант', 'First option');
  Add('Второй вариант', 'Second option');
  Add('Первая строка', 'First line');
  Add('Вторая строка', 'Second line');
  Add('Третья строка', 'Third line');
  Add('%d компонентов в палитре • %d ресурсов • Отмена: %d • Повтор: %d', '%d palette components • %d resources • Undo: %d • Redo: %d');
  Add('%d элементов (двойной щелчок)', '%d items (double-click)');
  Add(' элементов', ' items');
  Add(' строк', ' lines');
  Add('Текст (двойной щелчок)', 'Text (double-click)');
  Add('Изображение (двойной щелчок)', 'Image (double-click)');
  Add('Открыть редактор: ', 'Open editor: ');
  Add('Рабочая область: ', 'Workspace: ');
  Add('Изображения|*.png;*.jpg;*.jpeg;*.bmp', 'Images|*.png;*.jpg;*.jpeg;*.bmp');
  Add('Стили FireMonkey|*.style|Все файлы|*.*', 'FireMonkey styles|*.style|All files|*.*');
  Add('Стиль FireMonkey (*.style)|*.style|Текстовый стиль (*.style)|*.style', 'FireMonkey style (*.style)|*.style|Text style (*.style)|*.style');
  Add('Двойной щелчок по цвету открывает палитру. Связанные свойства обновляются автоматически.', 'Double-click a color to open the palette. Bound properties update automatically.');
  Add('Сохранить изменения текущего стиля?', 'Save changes to the current style?');
  Add('Буфер обмена недоступен.', 'Clipboard is unavailable.');
  Add('Буфер обмена не содержит текст DFM/FMX.', 'The clipboard does not contain DFM/FMX text.');
  Add('Буфер обмена не содержит текст TStyleBook.', 'The clipboard does not contain TStyleBook text.');
  Add('Скопируйте компонент TStyleBook из дизайнера Delphi.', 'Copy a TStyleBook component from the Delphi designer.');
  Add('Не удалось загрузить встроенные данные TStyleBook.', 'Could not load the embedded TStyleBook data.');
  Add('Буфер обмена должен содержать элементы стиля FMX.', 'The clipboard must contain FMX style objects.');
  Add('Буфер обмена не содержит элементов стиля.', 'The clipboard does not contain style objects.');
  Add('Выберите элемент стиля для копирования.', 'Select a style object to copy.');
  Add('Для копирования выберите элементы стиля.', 'Select style objects to copy.');
  Add('Выберите визуальный родительский объект в дереве.', 'Select a visual parent object in the tree.');
  Add('Анимацию или эффект нужно добавить в визуальный ресурс.', 'Add animations or effects inside a visual resource.');
  Add('Не удалось загрузить стиль.', 'Could not load the style.');
  Add('Системный стиль недоступен.', 'The system style is unavailable.');
  Add('Класс не найден: ', 'Class not found: ');
  Add('Предыдущий узел не может содержать визуальные объекты.', 'The previous node cannot contain visual objects.');
  Add('Невизуальный объект должен оставаться внутри ресурса.', 'A nonvisual object must remain inside a resource.');
  Add('Ресурс #designer должен быть TLayout.', 'The #designer resource must be a TLayout.');
  Add('Повтор служебного ресурса #designer.', 'Duplicate #designer service resource.');
  Add('Пустые данные проекта #designer.', 'Empty #designer project data.');
  Add('В #designer отсутствует TStyleTag project.', 'The #designer resource is missing the project TStyleTag.');
  Add('Задайте название группы.', 'Enter a group name.');
  Add('Группа не найдена.', 'Group not found.');
  Add('Некорректный файл коллекции ресурсов.', 'Invalid resource collection data.');
  Add('Неподдерживаемая версия коллекции ресурсов.', 'Unsupported resource collection version.');
  Add('Не найден объект связи: ', 'Binding target not found: ');
  Add('Тип объекта связи изменён: ', 'Binding target type has changed: ');
  Add('Отсутствует массив values в коллекции ресурсов.', 'The resource collection is missing the values array.');
  Add('Отсутствует массив bindings в коллекции ресурсов.', 'The resource collection is missing the bindings array.');
  Add('Повтор ресурса: ', 'Duplicate resource: ');
  Add('Некорректная группа стилей.', 'Invalid style group.');
  Add('Некорректная вложенность групп стилей.', 'Invalid style group nesting.');
  Add('Некорректная связь ресурса с группой.', 'Invalid resource group assignment.');
  Add('Некорректный снимок истории.', 'Invalid history snapshot.');
  Add('Это свойство доступно только для чтения.', 'This property is read-only.');
  Add('Свойство доступно только для чтения: ', 'Read-only property: ');
  Add('Для этого свойства нужен специальный редактор', 'This property requires a dedicated editor');
  Add('Используйте двойной щелчок для специального редактора.', 'Double-click to open the dedicated editor.');
  Add('Ожидается целое число или #AARRGGBB.', 'Expected an integer or #AARRGGBB.');
  Add('Число выходит за диапазон свойства.', 'The number is outside the property range.');
  Add('Число вне диапазона свойства', 'Number outside the property range');
  Add('Число вне диапазона свойства.', 'Number outside the property range.');
  Add('Ожидается конечное число', 'Expected a finite number');
  Add('Ожидается конечное число.', 'Expected a finite number.');
  Add('Ожидается один символ', 'Expected one character');
  Add('Ожидается один символ.', 'Expected one character.');
  Add('Допустимые значения: ', 'Allowed values: ');
  Add('Неизвестное значение перечисления', 'Unknown enumeration value');
  Add('Ожидается True или False', 'Expected True or False');
  Add('Ожидается целое число.', 'Expected an integer.');
  Add('Корневому ресурсу нужно имя StyleName.', 'A root resource requires a StyleName.');
  Add('Ресурс с таким StyleName уже существует.', 'A resource with this StyleName already exists.');
  Add('Имя #designer зарезервировано редактором.', 'The #designer name is reserved by the editor.');
  Add('Имя ресурса не может быть пустым.', 'The resource name cannot be empty.');
  Add('Для цвета укажите #AARRGGBB, например #FF247AC4.', 'Enter a color as #AARRGGBB, for example #FF247AC4.');
  Add('Логическое значение: True или False.', 'Boolean value: True or False.');
  Add('Типы ресурсов: Цвет, Число, Целое, Текст, Логическое.', 'Resource types: Color, Number, Integer, Text, Boolean.');
  Add('Цвет можно связать только со свойством TAlphaColor.', 'A color can only be bound to a TAlphaColor property.');
  Add('Числовой ресурс требует числового свойства.', 'A numeric resource requires a numeric property.');
  Add('Текстовый ресурс требует строкового свойства.', 'A text resource requires a string property.');
  Add('Логический ресурс требует свойства Boolean.', 'A Boolean resource requires a Boolean property.');
  Add('Выберите свойство и ресурс значения.', 'Select a property and a named value.');
  Add('Можно связать только редактируемое простое свойство.', 'Only editable scalar properties can be bound.');
  Add('Имя части стиля задаётся напрямую, без ссылки на значение.', 'Set the style part name directly, without a value binding.');
  Add('Ресурс с таким именем уже существует.', 'A resource with this name already exists.');
  Add(': у анимации не задано PropertyName', ': the animation has no PropertyName');
  Add(': свойство ', ': property ');
  Add(' не найдено у родителя', ' was not found on the parent');
  Add(': анимация выключена и не имеет Trigger', ': the animation is disabled and has no Trigger');
  Add(': отсутствует StyleName', ': missing StyleName');
  Add('Повторяющееся имя ресурса: ', 'Duplicate resource name: ');
  Add('Структура стиля проверена. Ошибок имён ресурсов и свойств анимаций не найдено.', 'Style validated. No resource name or animation property errors were found.');
  Language.Lang := 'ru';
end;

procedure TranslateForm(Form: TForm);
begin
  Form.Caption := TranslateUI(Form.Caption);
  for var I := 0 to Form.ComponentCount - 1 do
  begin
    var Component := Form.Components[I];
    // Only form UI participates; runtime document controls and resource names
    // must retain the author's text, even if it matches a translated caption.
    if (Component.Name = '') or (Component.Name = 'DocumentLabel') or
      (Component.Name = 'FValueReference') then
      Continue;
    if Component is TTextControl then
      TTextControl(Component).Text := TranslateUI(TTextControl(Component).Text);
    if Component is TPresentedTextControl then
      TPresentedTextControl(Component).Text := TranslateUI(TPresentedTextControl(Component).Text);
    if Component is TColumn then
      TColumn(Component).Header := TranslateUI(TColumn(Component).Header);
    if Component is TControl then
      TControl(Component).Hint := TranslateUI(TControl(Component).Hint);
    if Component is TComboBox then
      for var J := 0 to TComboBox(Component).Items.Count - 1 do
        TComboBox(Component).Items[J] := TranslateUI(TComboBox(Component).Items[J]);
    if (Component is TListBox) and (Component.Name = 'SampleList') then
      for var J := 0 to TListBox(Component).Items.Count - 1 do
        TListBox(Component).Items[J] := TranslateUI(TListBox(Component).Items[J]);
    if (Component is TEdit) and (Component.Name = 'SampleEdit') then
      TEdit(Component).Text := TranslateUI(TEdit(Component).Text);
  end;
end;

function CanonicalValueKind(const Display: string): string;
const
  Kinds: array[0..4] of string = ('Цвет', 'Число', 'Целое', 'Текст', 'Логическое');
begin
  Result := Display;
  for var Kind in Kinds do
    if SameText(Display, Kind) or SameText(Display, Translate(Kind)) then
      Exit(Kind);
end;

initialization

finalization
  OriginalUIStrings.Free;

end.

