unit MountPointController;

interface

uses
  DokanTorrentClass, Classes, System.Generics.Collections, System.SysUtils;

type
  TDokanTorrentController = class(TList<TDokanTorrentThread>)
  public
    constructor Create();
    destructor Destroy; override;
      //
    procedure MountAll;
    procedure UnmountAll;
    procedure Mount(const AItem: TDokanTorrentThread);
    procedure Unmount(const AItem: TDokanTorrentThread);
    procedure Clear;
  end;

implementation

{ TDokanTorrentController }

procedure TDokanTorrentController.Clear;
var
  FItem: TDokanTorrentThread;
begin
  for FItem in Self do
  begin
    FItem.Terminate;
    if FItem.Suspended then
      FItem.Resume;
  end;
  inherited;
end;

constructor TDokanTorrentController.Create;
begin
  inherited Create();
end;

destructor TDokanTorrentController.Destroy;
begin
  Clear;
  inherited;
end;

procedure TDokanTorrentController.Mount(const AItem: TDokanTorrentThread);
begin
  if Assigned(AItem) and AItem.Suspended then
    AItem.Resume;
end;

procedure TDokanTorrentController.MountAll;
var
  FItem: TDokanTorrentThread;
begin
  for FItem in Self do
    Mount(FItem);
end;

procedure TDokanTorrentController.UnmountAll;
var
  FItem: TDokanTorrentThread;
begin
  for FItem in Self do
    Unmount(FItem);
end;

procedure TDokanTorrentController.Unmount;
begin
  if Assigned(AItem) and (not AItem.Suspended) then
    AItem.Suspend;
end;

end.

