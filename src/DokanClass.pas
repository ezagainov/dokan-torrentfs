unit DokanClass;

interface

uses
  Dokan, sysutils, dialogs, classes, DokanWin, Winapi.Windows, madTools;

{$M+}

type
  TDokan = class(TComponent)
  private
    FOptions: PDokanOptions;
    FOperations: PDokanOperations;
    function DoGetVolumeInformation(VolumeNameBuffer: LPWSTR; VolumeNameSize: DWORD; var VolumeSerialNumber: DWORD; var MaximumComponentLength: DWORD; var FileSystemFlags: DWORD; FileSystemNameBuffer: LPWSTR; FileSystemNameSize: DWORD; var DokanFileInfo: DOKAN_FILE_INFO): NTSTATUS; stdcall;
    function DoFindFiles(FileName: LPCWSTR; FillFindData: TDokanFillFindData; var DokanFileInfo: DOKAN_FILE_INFO): NTSTATUS; stdcall;
    function DoCreateFile(FileName: LPCWSTR; var SecurityContext: DOKAN_IO_SECURITY_CONTEXT; DesiredAccess: ACCESS_MASK; FileAttributes: ULONG; ShareAccess: ULONG; CreateDisposition: ULONG; CreateOptions: ULONG; var DokanFileInfo: DOKAN_FILE_INFO): NTSTATUS; stdcall;
  public
    OnGetVolumeInformation: TDokanGetVolumeInformation;
    constructor Create; virtual;
    destructor Destroy; override;
    function Mount: Integer; virtual;
    function DoUnmount: Boolean;
    property Options: PDokanOptions read FOptions;
    property Operations: PDokanOperations read FOperations;
  published
    function GetVolumeInformation(VolumeNameBuffer: LPWSTR; VolumeNameSize: DWORD; var VolumeSerialNumber: DWORD; var MaximumComponentLength: DWORD; var FileSystemFlags: DWORD; FileSystemNameBuffer: LPWSTR; FileSystemNameSize: DWORD; var DokanFileInfo: DOKAN_FILE_INFO): NTSTATUS; virtual;
    function FindFiles(FileName: LPCWSTR; FillFindData: TDokanFillFindData; var DokanFileInfo: DOKAN_FILE_INFO): NTSTATUS; virtual;
    function CreateFile(FileName: LPCWSTR; var SecurityContext: DOKAN_IO_SECURITY_CONTEXT; DesiredAccess: ACCESS_MASK; FileAttributes: ULONG; ShareAccess: ULONG; CreateDisposition: ULONG; CreateOptions: ULONG; var DokanFileInfo: DOKAN_FILE_INFO): NTSTATUS; virtual;
  end;

  TDokanClass = class of TDokan;

implementation

{ TDokan }

function AddSeSecurityNamePrivilege(): Boolean;
var
  token: THandle;
  err: DWORD;
  luid: TLargeInteger;
  attr: LUID_AND_ATTRIBUTES;
  priv: TOKEN_PRIVILEGES;
  oldPriv: TOKEN_PRIVILEGES;
  retSize: DWORD;
  privAlreadyPresent: Boolean;
  i: Integer;
begin
  token := 0;
  if (not LookupPrivilegeValueW(nil, 'SeSecurityPrivilege', luid)) then
  begin
    err := GetLastError();
    if (err <> ERROR_SUCCESS) then
    begin
      Result := False;
      Exit;
    end;
  end;

  attr.Attributes := SE_PRIVILEGE_ENABLED;
  attr.Luid := luid;

  priv.PrivilegeCount := 1;
  priv.Privileges[0] := attr;

  if (not OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, token)) then
  begin
    err := GetLastError();
    if (err <> ERROR_SUCCESS) then
    begin
      Result := False;
      Exit;
    end;
  end;

  AdjustTokenPrivileges(token, False, priv, sizeof(TOKEN_PRIVILEGES), oldPriv, retSize);
  err := GetLastError();
  if (err <> ERROR_SUCCESS) then
  begin
    CloseHandle(token);
    Result := False;
    Exit;
  end;

  privAlreadyPresent := False;
  for i := 0 to oldPriv.PrivilegeCount - 1 do
  begin
    if (oldPriv.Privileges[i].Luid = luid) then
    begin
      privAlreadyPresent := True;
      Break;
    end;
  end;
  if (token <> 0) then
    CloseHandle(token);
  Result := True;
  Exit;
end;

constructor TDokan.Create;
var
  FClass: TDokanClass;
  Fptr: Pointer;
begin
  New(FOperations);
  if (FOperations = nil) then
  begin
    Free;
  end;
  New(FOptions);
  if (FOptions = nil) then
  begin
    Dispose(FOperations);
    Free;
  end;

  ZeroMemory(FOptions, sizeof(DOKAN_OPTIONS));
  FOptions^.Version := DOKAN_VERSION;
  FOptions^.ThreadCount := 5; // use default



  if (not AddSeSecurityNamePrivilege()) then
  begin
    Writeln(ErrOutput, 'Failed to add security privilege to process');
    Writeln(ErrOutput, #09'=> GetFileSecurity/SetFileSecurity may not work properly');
    Writeln(ErrOutput, #09'=> Please restart mirror sample with administrator ' + 'rights to fix it');
  end;

  FOptions^.Options := FOptions^.Options or DOKAN_OPTION_DEBUG or DOKAN_OPTION_MOUNT_MANAGER or DOKAN_OPTION_ALT_STREAM;
 // FOptions^.Options := FOptions^.Options or DOKAN_OPTION_ALT_STREAM;



  ZeroMemory(FOperations, sizeof(DOKAN_OPERATIONS));

  FOperations^.GetVolumeInformation := MethodToProcedure(Self, @TDokan.DoGetVolumeInformation);
  FOperations^.FindFiles := MethodToProcedure(Self, @TDokan.DoFindFiles);
  FOperations^.ZwCreateFile := MethodToProcedure(Self, @TDokan.DoCreateFile);

end;

function TDokan.CreateFile(FileName: LPCWSTR; var SecurityContext: DOKAN_IO_SECURITY_CONTEXT; DesiredAccess: ACCESS_MASK; FileAttributes, ShareAccess, CreateDisposition, CreateOptions: ULONG; var DokanFileInfo: DOKAN_FILE_INFO): NTSTATUS;
begin
  Result := DOKAN_SUCCESS;
end;

destructor TDokan.Destroy;
begin
  Dispose(FOptions);
  Dispose(FOperations);
  inherited;
end;

function TDokan.DoCreateFile(FileName: LPCWSTR; var SecurityContext: DOKAN_IO_SECURITY_CONTEXT; DesiredAccess: ACCESS_MASK; FileAttributes, ShareAccess, CreateDisposition, CreateOptions: ULONG; var DokanFileInfo: DOKAN_FILE_INFO): NTSTATUS;
begin
  Result := self.CreateFile(FileName, SecurityContext, DesiredAccess, FileAttributes, ShareAccess, CreateDisposition, CreateOptions, DokanFileInfo);
end;

function TDokan.DoFindFiles(FileName: LPCWSTR; FillFindData: TDokanFillFindData; var DokanFileInfo: DOKAN_FILE_INFO): NTSTATUS;
begin
  Result := FindFiles(FileName, FillFindData, DokanFileInfo);
end;

function TDokan.DoGetVolumeInformation(VolumeNameBuffer: LPWSTR; VolumeNameSize: DWORD; var VolumeSerialNumber, MaximumComponentLength, FileSystemFlags: DWORD; FileSystemNameBuffer: LPWSTR; FileSystemNameSize: DWORD; var DokanFileInfo: DOKAN_FILE_INFO): NTSTATUS;
begin
  Result := GetVolumeInformation(VolumeNameBuffer, VolumeNameSize, VolumeSerialNumber, MaximumComponentLength, FileSystemFlags, FileSystemNameBuffer, FileSystemNameSize, DokanFileInfo)
end;

function TDokan.DoUnmount: Boolean;
begin
  Result := DokanUnmount(Options^.MountPoint^)
end;

function TDokan.FindFiles(FileName: LPCWSTR; FillFindData: TDokanFillFindData; var DokanFileInfo: DOKAN_FILE_INFO): NTSTATUS;
begin
  Result := DOKAN_SUCCESS;
end;

function TDokan.GetVolumeInformation(VolumeNameBuffer: LPWSTR; VolumeNameSize: DWORD; var VolumeSerialNumber, MaximumComponentLength, FileSystemFlags: DWORD; FileSystemNameBuffer: LPWSTR; FileSystemNameSize: DWORD; var DokanFileInfo: DOKAN_FILE_INFO): NTSTATUS;
begin
  Result := DOKAN_SUCCESS;
end;

function TDokan.Mount: Integer;
begin
//  try
  Result := DokanMain(FOptions^, FOperations^);
//  finally
//    DoUnmount;
//  end;
  case (Result) of
//    DOKAN_SUCCESS:



    DOKAN_ERROR:
      Writeln(ErrOutput, 'Error');
    DOKAN_DRIVE_LETTER_ERROR:
      Writeln(ErrOutput, 'Bad Drive letter');
    DOKAN_DRIVER_INSTALL_ERROR:
      Writeln(ErrOutput, 'Can''t install driver');
    DOKAN_START_ERROR:
      Writeln(ErrOutput, 'Driver something wrong');
    DOKAN_MOUNT_ERROR:
      Writeln(ErrOutput, 'Can''t assign a drive letter');
    DOKAN_MOUNT_POINT_ERROR:
      Writeln(ErrOutput, 'Mount point error');
    DOKAN_VERSION_ERROR:
      Writeln(ErrOutput, 'Version error');
  else
//    Writeln(ErrOutput, 'Unknown error: ', Result);





  end;
end;

end.

