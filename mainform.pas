unit MainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, IpHtml, Ipfilebroker, Forms, Controls, Graphics,
  Dialogs, Menus, Process, LResources, fileinfo, winpeimagereader,
  elfreader, machoreader;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    htmlPMain: TIpHtmlPanel;
    htmlFileProvider: TIpFileDataProvider;
    mnuHelp: TMenuItem;
    mnuHelpAbout: TMenuItem;
    mnuMain: TMainMenu;
    mnuFile: TMenuItem;
    mnuFileQuit: TMenuItem;
    mnuFileOpen: TMenuItem;
    dlgOpen: TOpenDialog;
    procedure mnuHelpAboutClick(Sender: TObject);
    procedure mnuFileOpenClick(Sender: TObject);
    procedure mnuFileQuitClick(Sender: TObject);
    procedure OpenFileForDisplay(filename: string);
    procedure ShowWelcomeMessage();
    procedure Restart();
    constructor Create(AOwner: TComponent); override;
  private
    { private declarations }
  public
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }
procedure TfrmMain.mnuFileOpenClick(Sender: TObject);
var
  filename: string;
begin

  if dlgOpen.Execute then
  begin
    filename := dlgOpen.Filename;
    OpenFileForDisplay(filename);
  end;

end;

procedure TfrmMain.mnuFileQuitClick(Sender: TObject);
begin

  Close;

end;

procedure TfrmMain.mnuHelpAboutClick(Sender: TObject);
var
  finfo: TFileVersionInfo;
  output: string;
begin
  finfo := TFileVersionInfo.Create(nil);
  finfo.ReadFileInfo;
  output := finfo.VersionStrings.Values['ProductName'] + ' v' +
    finfo.VersionStrings.Values['FileVersion'] + sLineBreak + sLineBreak;
  output += finfo.VersionStrings.Values['Comments'] +
    sLineBreak + sLineBreak;
  output += finfo.VersionStrings.Values['FileDescription'] +
    sLineBreak + sLineBreak;
  output += finfo.VersionStrings.Values['LegalCopyright'];

  ShowMessage(output);

end;


procedure TfrmMain.OpenFileForDisplay(filename: string);
var
  outbuf: string;
  pandocexe: string;
begin
  {$IFDEF Windows}
  pandocexe := 'pandoc.exe';
  {$ELSE}
  pandocexe := 'pandoc';
  {$ENDIF}

  if FileExists(filename) then
  begin

    try
		  // http://wiki.freepascal.org/Executing_External_Programs#TProcess
      // why no exceptions?????
      if RunCommand(pandocexe, [filename], outbuf) then
        htmlPMain.SetHtmlFromStr(outbuf)
      else
        ShowMessage('Conversion from pandoc failed! Cannot display this file.');

    except
      on E: EProcess do
        ShowMessage('Error: ' + E.ClassName + #13#10 + E.Message);
      on E: Exception do
        ShowMessage('Error: ' + E.ClassName + #13#10 + E.Message);

    end;

  end
  else
    ShowMessage('File does not appear to exist: ' + filename);

end;

procedure TfrmMain.ShowWelcomeMessage();
var
  outbuf: string =
  '<html><head><title>Welcome!</title></head><body><center><br/><br/><p>Welcome!</p><p>To view a file, go to File > Open...</p></center></body></html>';
begin
  htmlPMain.SetHtmlFromStr(outbuf);
end;


procedure TFrmMain.Restart;
begin
  ShowWelcomeMessage;
end;

constructor TFrmMain.Create(AOwner: TComponent);
var
  param: string = '';
begin
  inherited Create(AOwner);
  ShowWelcomeMessage();

  if (ParamCount = 1) then
    param := ParamStr(1);

  if (param <> '') then
  begin
    OpenFileForDisplay(param);
  end;

end;

end.
