program DokanTorrentGUI;

uses
  DUnitX.MemoryLeakMonitor.FastMM4,
  Vcl.Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  DokanClass in '..\DokanClass.pas',
  DokanThread in '..\DokanThread.pas',
  TorrentUtils in '..\TorrentUtils.pas',
  madTools in '..\..\xtra\madBasic\madTools.pas',
  BEncode in '..\..\xtra\BEncode.pas',
  Dokan in '..\..\xtra\dokan-delphi\Dokan.pas',
  DokanWin in '..\..\xtra\dokan-delphi\DokanWin.pas',
  DokanTorrentClass in '..\DokanTorrentClass.pas',
  MountPointController in '..\MountPointController.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

