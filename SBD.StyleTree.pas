unit SBD.StyleTree;

interface

uses
  System.Classes, System.Types, System.UITypes, FMX.Types, FMX.TreeView;

type
  TStyleTreeView = class(TTreeView)
  private
    FSelecting: Boolean;
    FRangeAnchor: TTreeViewItem;
    procedure SetRangeAnchor(Value: TTreeViewItem);
  protected
    procedure DoChange; override;
    procedure SetSelected(const Value: TTreeViewItem); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    function SelectedItems: TArray<TTreeViewItem>;
    procedure ChooseItem(Item: TTreeViewItem; Shift: TShiftState; RightClick: Boolean = False);
    procedure RefreshOrder;
  end;

function TreeItems(Tree: TTreeView): TArray<TTreeViewItem>;

implementation

uses
  System.Math, System.Generics.Collections;

function TreeItems(Tree: TTreeView): TArray<TTreeViewItem>;
var
  Items: TList<TTreeViewItem>;

  procedure Visit(Item: TTreeViewItem);
  begin
    Items.Add(Item);
    for var I := 0 to Item.Count - 1 do
      Visit(Item.Items[I]);
  end;

begin
  Items := TList<TTreeViewItem>.Create;
  try
    for var I := 0 to Tree.Count - 1 do
      Visit(Tree.Items[I]);
    Result := Items.ToArray;
  finally
    Items.Free;
  end;
end;

function TStyleTreeView.SelectedItems: TArray<TTreeViewItem>;
var
  Items: TList<TTreeViewItem>;
begin
  Items := TList<TTreeViewItem>.Create;
  try
    for var Item in TreeItems(Self) do
      if Item.IsSelected then
        Items.Add(Item);
    Result := Items.ToArray;
  finally
    Items.Free;
  end;
end;

procedure TStyleTreeView.DoChange;
begin
  if not FSelecting then
    inherited;
end;

procedure TStyleTreeView.SetRangeAnchor(Value: TTreeViewItem);
begin
  if FRangeAnchor = Value then
    Exit;
  if FRangeAnchor <> nil then
    FRangeAnchor.RemoveFreeNotification(Self);
  FRangeAnchor := Value;
  if FRangeAnchor <> nil then
    FRangeAnchor.FreeNotification(Self);
end;

procedure TStyleTreeView.SetSelected(const Value: TTreeViewItem);
begin
  if FSelecting then
  begin
    inherited;
    Exit;
  end;
  FSelecting := True;
  try
    for var Item in SelectedItems do
      if Item <> Value then
        Item.IsSelected := False;
    inherited;
    SetRangeAnchor(Value);
  finally
    FSelecting := False;
  end;
  DoChange;
end;

procedure TStyleTreeView.ChooseItem(Item: TTreeViewItem; Shift: TShiftState; RightClick: Boolean);
var
  Keep, Active: TTreeViewItem;
  ToggleOff: Boolean;
  First, Last: Integer;
begin
  if Item = nil then
    Exit;
  FSelecting := True;
  try
    Active := Item;
    if (ssShift in Shift) and not RightClick and (FRangeAnchor <> nil) and
      (FRangeAnchor.Level = Item.Level) then
    begin
      First := Min(FRangeAnchor.GlobalIndex, Item.GlobalIndex);
      Last := Max(FRangeAnchor.GlobalIndex, Item.GlobalIndex);
      for var Node in TreeItems(Self) do
        Node.IsSelected := False;
      for var I := First to Last do
      begin
        var Node := ItemByGlobalIndex(I);
        if Node.Level = Item.Level then
          Node.IsSelected := True;
      end;
    end
    else if ((ssCtrl in Shift) and not RightClick) or (RightClick and Item.IsSelected) then
    begin
      ToggleOff := (ssCtrl in Shift) and not RightClick and Item.IsSelected;
      for Keep in SelectedItems do
        if Keep.Level <> Item.Level then
          Keep.IsSelected := False;
      Item.IsSelected := not ToggleOff;
      if ToggleOff then
      begin
        Active := nil;
        for Keep in SelectedItems do
          Active := Keep;
      end;
      SetRangeAnchor(Active);
    end
    else
    begin
      for Keep in SelectedItems do
        Keep.IsSelected := False;
      Item.IsSelected := True;
      SetRangeAnchor(Item);
    end;
    inherited SetSelected(Active);
  finally
    FSelecting := False;
  end;
  DoChange;
end;

procedure TStyleTreeView.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Item, Anchor: TTreeViewItem;
  Previous: TArray<TTreeViewItem>;
  DragAllowed, KeepSelection: Boolean;
begin
  Item := ItemByPoint(X, Y);
  KeepSelection := (Item <> nil) and Item.IsSelected and
    (Button = TMouseButton.mbLeft) and ([ssCtrl, ssShift] * Shift = []);
  Previous := SelectedItems;
  Anchor := FRangeAnchor;
  DragAllowed := AllowDrag;
  FSelecting := True;
  MultiSelect := False;
  if [ssCtrl, ssShift] * Shift <> [] then
    AllowDrag := False;
  try
    inherited;
  finally
    AllowDrag := DragAllowed;
    MultiSelect := True;
    FSelecting := False;
  end;
  if (Item <> nil) and (Button in [TMouseButton.mbLeft, TMouseButton.mbRight]) then
  begin
    FSelecting := True;
    try
      for var Node in TreeItems(Self) do
        Node.IsSelected := False;
      for var Node in Previous do
        Node.IsSelected := True;
      SetRangeAnchor(Anchor);
    finally
      FSelecting := False;
    end;
    ChooseItem(Item, Shift, (Button = TMouseButton.mbRight) or KeepSelection);
  end;
end;

procedure TStyleTreeView.KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
var
  Target: TTreeViewItem;
  Index, Direction: Integer;
begin
  if (Key = Ord('A')) and (ssCtrl in Shift) and (Selected <> nil) then
  begin
    FSelecting := True;
    try
      for var Node in TreeItems(Self) do
        Node.IsSelected := False;
      for var I := 0 to GlobalCount - 1 do
      begin
        var Node := ItemByGlobalIndex(I);
        Node.IsSelected := (Node.Level = Selected.Level) and Node.IsVisible;
      end;
    finally
      FSelecting := False;
    end;
    Key := 0;
    DoChange;
    Exit;
  end;
  if (Selected <> nil) and (Key in [vkUp, vkDown, vkHome, vkEnd]) then
  begin
    Index := Selected.GlobalIndex;
    Direction := 1;
    if Key in [vkUp, vkHome] then
      Direction := -1;
    if Key = vkHome then
    begin
      Index := -1;
      Direction := 1;
    end
    else if Key = vkEnd then
    begin
      Index := GlobalCount;
      Direction := -1;
    end;
    Target := Selected;
    repeat
      Inc(Index, Direction);
      if (Index < 0) or (Index >= GlobalCount) then
        Break;
      var Node := ItemByGlobalIndex(Index);
      if Node.IsVisible and (not (ssShift in Shift) or (Node.Level = Selected.Level)) then
      begin
        Target := Node;
        Break;
      end;
    until False;
    ChooseItem(Target, Shift - [ssCtrl]);
    Key := 0;
    Exit;
  end;
  inherited;
end;

procedure TStyleTreeView.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FRangeAnchor) then
    FRangeAnchor := nil;
  inherited;
end;

procedure TStyleTreeView.RefreshOrder;
begin
  // FMX skips global-index invalidation when row Index changes during a batch.
  // Notify the content once, before EndUpdate calculates geometry and hit tests.
  if Count > 0 then
    ContentInsertObject(0, Items[0]);
end;

end.

