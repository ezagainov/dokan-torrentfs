unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Generics.Collections,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  DokanTorrentClass, DokanThread, Dokan, Vcl.Buttons, Vcl.StdCtrls, Vcl.ComCtrls,
  System.Actions, Vcl.ActnList, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnMan,
  Vcl.ToolWin, Vcl.ActnCtrls, MountPointController;

type
  TMainForm = class(TForm)
    lvMountController: TListView;
    ActionToolBar1: TActionToolBar;
    amActions: TActionManager;
    actMountAll: TAction;
    actUnmountAll: TAction;
    actClear: TAction;
    actAddTest: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actMountAllExecute(Sender: TObject);
    procedure actUnmountAllExecute(Sender: TObject);
    procedure lvMountControllerInsert(Sender: TObject; Item: TListItem);
    procedure actClearExecute(Sender: TObject);
  private
    FController: TDokanTorrentController;
    procedure DoOnUpdateMountpoint(Sender: TObject; const Item: TDokanTorrentThread; Action: System.Generics.Collections.TCollectionNotification);
    procedure InsertTestData(const AMountPoint: string = 'O');
  public
    { Public declarations }
  end;

  TTorrentDokan = class(TDokanTorrent)
  protected
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}
procedure TMainForm.DoOnUpdateMountpoint(Sender: TObject; const Item: TDokanTorrentThread; Action: System.Generics.Collections.TCollectionNotification);
var
  MountLvItem: TListItem;
begin
  if Action = System.Generics.Collections.cnAdded then
  begin
    MountLvItem := TListItem.Create(lvMountController.items);
    MountLvItem.Data := Pointer(Item);
    lvMountController.Items.AddItem(MountLvItem)
  end;
  if Action = System.Generics.Collections.cnRemoved then
  begin
    MountLvItem := lvMountController.FindData(0, Pointer(Item), true, False);
    if Assigned(MountLvItem) then
      lvMountController.Items.Delete(MountLvItem.Index);

  end;

end;

procedure TMainForm.actClearExecute(Sender: TObject);
begin
  FController.Clear;
end;

procedure TMainForm.actMountAllExecute(Sender: TObject);
begin
  FController.MountAll;
end;

procedure TMainForm.actUnmountAllExecute(Sender: TObject);
begin
  FController.UnmountAll;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FController) then
    FreeAndNil(FController);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FController := TDokanTorrentController.Create;
  FController.OnNotify := DoOnUpdateMountpoint;
  //
  InsertTestData('F');
  InsertTestData('G');
    InsertTestData('H');
end;

procedure TMainForm.InsertTestData(const AMountPoint: string = 'O');
var
  Drv: TDokanTorrentThread;
begin
  Drv := TDokanTorrentThread.Create();
  with Drv do
  begin
    Drive.Options.Options := Drive.Options.Options or DOKAN_OPTION_DEBUG;
    StringToWideChar(AMountPoint, Drive.Options.MountPoint, 1);

    Drive.torrentFile := '..\test\[rutracker.org].t1528435.torrent';
  end;
  FController.Add(Drv);
end;

procedure TMainForm.lvMountControllerInsert(Sender: TObject; Item: TListItem);
var
  FItem: TDokanTorrentThread;
begin
  FItem := TDokanTorrentThread(Item.Data);
  if Assigned(FItem) then
  begin
    Item.Caption := FItem.Drive.TorrentFile;
    while Item.SubItems.count <> (lvMountController.Columns.Count - 1) do
      Item.SubItems.Add('');
    Item.SubItems.Strings[0] := FItem.Drive.Options.MountPoint;
    Item.SubItems.Strings[1] := BoolToStr(FItem.Suspended, true);
  end;

end;

end.

