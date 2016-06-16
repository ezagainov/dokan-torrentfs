unit DokanThread;

interface

uses
  Windows, SysUtils, Classes, DokanClass, Vcl.Forms;

type
  TDokanThread<T: constructor, TDokan> = class(TThread)
  private
    FDrive: T;
  public
    constructor Create;
    procedure Execute; override;
    procedure Terminate;
    property Drive: T read FDrive write FDrive;
  end;

implementation

constructor TDokanThread<T>.Create;
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FDrive := T.Create;
end;

procedure TDokanThread<T>.Execute;
var
  R: Integer;
begin
  FDrive.Mount;
end;

procedure TDokanThread<T>.Terminate;
begin
  FDrive.DoUnmount;
  FDrive.Free;
end;

end.

