unit TorrentUtils;

interface

uses
  System.Classes, Winapi.Windows, System.SysUtils, System.Generics.Collections,
  BEncode;

type
  TFileRec = class;

  TFileRecList = class(TList<TFileRec>)
  public
    function Find(const AName: string): TFileRec;
    destructor Destroy; override;
    procedure Clear;
  end;

  TFileRec = class
    public
      Size: int64;
      isDir: Boolean;
      FileName: string;
      Childs: TFileRecList;
      destructor Destroy; override;
  end;

type
  TTorrentHeader = class(TObject)
  private
    FStream: TFileStream;
    FBencoded: TBEncoded;
    FFiles: TFileRec;
    FName: string;
    function PathStr(AList: TBEncodedDataList): string;
  public
    constructor Create(AFile: string);
    destructor Destroy; override;
    property BEncoded: TBEncoded read FBencoded;
    property Files: TFileRec read FFiles;
    property Name: string read FName;
  end;

implementation



{ TTorrentHeader }

constructor TTorrentHeader.Create(AFile: string);
var
  F, P, Nodes, Lst: Integer;
  FList, FPathList: TBEncodedDataList;
  FRec, FRoot, FlastDir: TFileRec;
  FName: string;
begin
  FStream := TFileStream.Create(AFile, fmShareDenyNone);
  FStream.Seek(0, 0);
  FBencoded := TBEncoded.Create(FStream);
  FFiles := TFileRec.Create;
  self.FName := FBencoded.ListData.FindElement('info').data.listdata.FindElement('name').data.AnsiStringData;
  try
    FList := FBencoded.ListData.FindElement('info').Data.ListData.FindElement('files').Data.ListData;
    FRoot := FFiles;
    FRoot.isDir := True;
    FRoot.FileName := PathDelim;
    FRoot.Childs := TFileRecList.Create;

    for Nodes := 0 to FList.Count - 1 do
    begin
      FPathList := FList.Items[Nodes].Data.ListData.FindElement('path').Data.ListData;
      FlastDir := FRoot;
      for Lst := 0 to FPathList.Count - 1 do
      begin
        FName := FPathList.items[Lst].data.AnsiStringData;
        FRec := TFileRec.Create;
        FRec.isDir := Lst < FPathList.Count - 1;
        FRec.FileName := Fname;
        FRec.Childs := TFileRecList.Create;
        if FRec.isDir then
        begin
          if Assigned(FlastDir.Childs.Find(FName)) then
            FlastDir := FlastDir.Childs.Find(FName)
          else
          begin
            FlastDir.Childs.Add(Frec);
            FlastDir := FRec;
          end;

        end
        else
          FlastDir.Childs.Add(Frec);
      end;
      if not Frec.isDir then
        Frec.Size := FList.Items[Nodes].Data.ListData.FindElement('length').Data.IntegerData;
    end;
  except

  end;
end;

destructor TTorrentHeader.Destroy;
begin
  FreeAndNil(FBencoded);
  FreeAndNil(FStream);
  FreeAndNil(FFiles);
  inherited;
end;

function TTorrentHeader.PathStr(AList: TBEncodedDataList): string;
var
  c: integer;
begin
  Result := '';
  for c := 0 to AList.Count - 1 do
  begin
    Result := IncludeTrailingBackslash(Result) + AnsiToUtf8(AList.Items[c].Data.AnsiStringData);
  end;

end;


{ TFileRecList }

procedure TFileRecList.Clear;
var
  FItem: TFileRec;
begin
  for FItem in Self do
    FItem.Free;
  inherited;
end;

destructor TFileRecList.Destroy;
begin
  Clear;
  inherited;
end;

function TFileRecList.Find(const AName: string): TFileRec;
var
  FRec: TFileRec;
begin
  Result := nil;
  for FRec in Self do
  begin
    if FRec.FileName = AName then
    begin
      Result := FRec;
      Exit;
    end;

  end;

end;

{ TFileRec }

destructor TFileRec.Destroy;
begin
  FreeAndNil(Childs);
  inherited;
end;

end.

