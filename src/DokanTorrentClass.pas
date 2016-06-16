unit DokanTorrentClass;

interface

uses
  Dokan, sysutils, dialogs, classes, DokanWin, Winapi.Windows, madTools,
  DokanClass, TorrentUtils, DokanThread;

type
  TDokanTorrent = class(TDokan)
  private
    FTorrentFileHandler: TTorrentHeader;
    FTorrentFile: string;
    procedure SetTorrentFile(const Value: string);
    procedure ParseTorrent;
  public
    constructor Create; override;
    destructor Destroy; override;
    function Mount: Integer; override;
  published
    property TorrentFile: string read FTorrentFile write SetTorrentFile;
    function GetVolumeInformation(VolumeNameBuffer: LPWSTR; VolumeNameSize: DWORD; var VolumeSerialNumber: DWORD; var MaximumComponentLength: DWORD; var FileSystemFlags: DWORD; FileSystemNameBuffer: LPWSTR; FileSystemNameSize: DWORD; var DokanFileInfo: DOKAN_FILE_INFO): NTSTATUS; override;
    function FindFiles(FileName: LPCWSTR; FillFindData: TDokanFillFindData; var DokanFileInfo: DOKAN_FILE_INFO): NTSTATUS; override;
  end;

  TDokanTorrentThread = class(TDokanThread<TDokanTorrent>);

implementation


{ TDokanTest }

constructor TDokanTorrent.Create;
begin
  inherited;
end;

function FileTimeToDateTime(FileTime: TFileTime): TDateTime;
var
  ModifiedTime: TFileTime;
  SystemTime: TSystemTime;
begin
  Result := 0;
  if (FileTime.dwLowDateTime = 0) and (FileTime.dwHighDateTime = 0) then
    Exit;
  try
    FileTimeToLocalFileTime(FileTime, ModifiedTime);
    FileTimeToSystemTime(ModifiedTime, SystemTime);
    Result := SystemTimeToDateTime(SystemTime);
  except
    Result := Now;  // Something to return in case of error
  end;
end;

function DateTimeToFileTime(FileTime: TDateTime): TFileTime;
var
  LocalFileTime, Ft: TFileTime;
  SystemTime: TSystemTime;
begin
  Result.dwLowDateTime := 0;
  Result.dwHighDateTime := 0;
  DateTimeToSystemTime(FileTime, SystemTime);
  SystemTimeToFileTime(SystemTime, LocalFileTime);
  LocalFileTimeToFileTime(LocalFileTime, Ft);
  Result := Ft;
end;

destructor TDokanTorrent.Destroy;
begin
  FreeAndNil(FTorrentFileHandler);
  inherited;
end;

function TDokanTorrent.FindFiles(FileName: LPCWSTR; FillFindData: TDokanFillFindData; var DokanFileInfo: DOKAN_FILE_INFO): NTSTATUS;
var
  findData: TWIN32FindDataW;
  FileSize: Int64;
  FLo, LHi: Cardinal;
  Delimited: TStringList;
  S: string;
  R, fr: Tfilerec;

  procedure write_file_info(r: TFileRec);
  begin
    StrLCopy(findData.cFileName, PChar(r.FileName), length(r.FileName));
    findData.ftCreationTime := DateTimeToFileTime(Now);
    findData.ftLastAccessTime := DateTimeToFileTime(Now);
    findData.ftLastWriteTime := DateTimeToFileTime(Now);
    if r.isDir then
      findData.dwFileAttributes := FILE_ATTRIBUTE_DIRECTORY
    else
    begin
      FileSize := Int64(r.Size);

      findData.dwFileAttributes := FILE_ATTRIBUTE_NORMAL or FILE_ATTRIBUTE_READONLY;
    end;
    findData.nFileSizeHigh := 0;
    findData.nFileSizeLow := FileSize;
    if FileSize > Int64(High(Cardinal)) then
    begin
      findData.nFileSizeLow := LongWord(FileSize and $FFFFFFFF);
      findData.nFileSizeHigh := LongWord(FileSize shr 32);
    end;
    FillFindData(findData, DokanFileInfo);
  end;

begin

  if filename = '\' then
  begin
    r := FTorrentFileHandler.Files;

  end
  else
  begin

    Delimited := TStringList.Create;
    Delimited.Delimiter := '\';
    Delimited.StrictDelimiter := True;
    Delimited.DelimitedText := filename;
    Delimited.Delete(0);
    r := FTorrentFileHandler.Files;
    for s in Delimited do
    begin
      if s = emptystr then
        break;
      fr := r.Childs.Find(s);
      if Assigned(fr) then
        r := fr
      else
      begin
        r := nil;
        Break;
      end;
    end;
  end;

  if Assigned(r) then
  begin
    if r.isDir then
    begin
      for fr in r.childs do
        write_file_info(fr);
    end
    else
      write_file_info(r);

  end;

  Result := DOKAN_SUCCESS;

end;

function TDokanTorrent.GetVolumeInformation(VolumeNameBuffer: LPWSTR; VolumeNameSize: DWORD; var VolumeSerialNumber, MaximumComponentLength, FileSystemFlags: DWORD; FileSystemNameBuffer: LPWSTR; FileSystemNameSize: DWORD; var DokanFileInfo: DOKAN_FILE_INFO): NTSTATUS;
begin
  StringToWideChar(FTorrentFileHandler.Name, VolumeNameBuffer, VolumeNameSize);
  VolumeSerialNumber := $19831116;
  MaximumComponentLength := 256;
  FileSystemFlags := FILE_CASE_SENSITIVE_SEARCH or FILE_CASE_PRESERVED_NAMES or FILE_SUPPORTS_REMOTE_STORAGE or FILE_UNICODE_ON_DISK or FILE_PERSISTENT_ACLS or FILE_READ_ONLY_VOLUME;
  lstrcpynW(FileSystemNameBuffer, 'NTFS', FileSystemNameSize);
  Result := STATUS_SUCCESS;
end;

function TDokanTorrent.Mount: Integer;
begin
  if Assigned(FTorrentFileHandler) then
    Result := inherited Mount
  else
    Result := DOKAN_ERROR;
end;

procedure TDokanTorrent.ParseTorrent;
var
  FMStream: TMemoryStream;
begin
  if Assigned(FTorrentFileHandler) then
  begin
    FreeAndNil(FTorrentFileHandler);
  end;
  FTorrentFileHandler := TTorrentHeader.Create(FTorrentFile);
end;

procedure TDokanTorrent.SetTorrentFile(const Value: string);
begin
  FTorrentFile := Value;
  ParseTorrent;
  DoUnmount;
end;

end.

