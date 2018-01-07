unit MainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Windows, types;

type
  TWindowInfo = record
    Title: string;
    Handle: THandle;
    Icon: HIcon;
  end;

  { TMain }

  TMain = class(TForm)
    btRefresh: TButton;
    btFullscreenize: TButton;
    btHelp: TButton;
    cbApplyStayOnTop: TCheckBox;
    Label1: TLabel;
    lbWindows: TListBox;
    procedure btFullscreenizeClick(Sender: TObject);
    procedure btHelpClick(Sender: TObject);
    procedure btRefreshClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lbWindowsDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
  private
    { private declarations }
  public
    Wins: array of TWindowInfo;
    procedure DestroyWindowInfo;
    procedure RefreshWindows;
    procedure AddWindow(AHandle: THandle; ATitle: string; AIcon: HIcon);
  end;

var
  Main: TMain;

implementation

{$R *.lfm}

{ TMain }

function WindowsEnumerator(_para1:HWND; _para2:LPARAM):WINBOOL;stdcall;
var
  Title: array [0..1024] of UnicodeChar;
  TitStr: UTF8String;
  Icon: HICON;
begin
  if not IsWindowVisible(_para1) then Exit(True);
  GetWindowTextW(_para1, @Title, 1024);
  TitStr:=Title;
  if Trim(TitStr)='' then Exit(True);
  Icon:=HICON(SendMessage(_para1, WM_GETICON, ICON_SMALL, 0));
  if Icon=0 then Icon:=HICON(GetClassLongPtr(_para1, GCL_HICONSM));
  if Icon=0 then Icon:=HICON(GetClassLongPtr(_para1, GCL_HICON));
  if Icon <> 0 then Icon:=CopyIcon(Icon);
  Main.AddWindow(_para1, TitStr, Icon);
  Result:=True;
end;

procedure TMain.btRefreshClick(Sender: TObject);
begin
  RefreshWindows;
end;

procedure TMain.FormCreate(Sender: TObject);
begin
  RefreshWindows;
end;

procedure TMain.FormDestroy(Sender: TObject);
begin
  DestroyWindowInfo;
end;

procedure TMain.lbWindowsDrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
begin
  with lbWindows.Canvas do begin
    Pen.Color:=Brush.Color;
    Rectangle(ARect);
    TextOut(ARect.Left + 18, ARect.Top + 1, lbWindows.Items[Index]);
    DrawIconEx(Handle, ARect.Left, ARect.Top, Wins[Index].Icon, 16, 16, 0, 0, DI_NORMAL);
  end;
end;

procedure TMain.DestroyWindowInfo;
var
  I: Integer;
begin
  for I:=0 to High(Wins) do begin
    if Wins[I].Icon <> 0 then DestroyIcon(Wins[I].Icon);
  end;
  SetLength(Wins, 0);
end;

procedure TMain.btFullscreenizeClick(Sender: TObject);
var
  FinalRect: TRect;
  Win: HWND;
begin
  if lbWindows.ItemIndex < 0 then begin
    ShowMessage('Please select a window first.');
    Exit;
  end;
  if lbWindows.ItemIndex >= Length(Wins) then begin
    RefreshWindows;
    ShowMessage('Please select a window after refreshing the list first.');
    Exit;
  end;
  Win:=Wins[lbWindows.ItemIndex].Handle;
  FinalRect.Left:=0;
  FinalRect.Top:=0;
  FinalRect.Right:=Screen.Width;
  FinalRect.Bottom:=Screen.Height;
  SetWindowLong(Win, GWL_STYLE, LONG(WS_POPUP or WS_VISIBLE));
  AdjustWindowRect(FinalRect, GetWindowLong(Win, GWL_STYLE), False);
  if cbApplyStayOnTop.Checked then SetWindowLong(Win, GWL_EXSTYLE, GetWindowLong(Win, GWL_EXSTYLE) or WS_EX_TOPMOST);
  MoveWindow(Win, FinalRect.Left, FinalRect.Top, FinalRect.Right - FinalRect.Left, FinalRect.Bottom - FinalRect.Top, True);
end;

procedure TMain.btHelpClick(Sender: TObject);
begin
  ShowMessage('Open the game you want to force in borderless-windowed-fullscreen mode, '+
              'set it to windowed mode to the resolution you want, hit the Refresh button '+
              'to refresh the windows list, select the game window from the list and press '+
              'the Fullscreenize button.  The window will be resized to the desktop area and '+
              'the border will be removed.  Note that using a different in-game resolution '+
              'from the desktop resolution may not work properly (or at all) depending on the game.'+LineEnding+LineEnding+LineEnding+
              'Made by Kostas "Bad Sector" Michalopoulos');
end;

procedure TMain.RefreshWindows;
var
  I: Integer;
begin
  DestroyWindowInfo;
  EnumWindows(@WindowsEnumerator, 0);
  lbWindows.Clear;
  for I:=0 to High(Wins) do begin
    lbWindows.Items.Add(Wins[I].Title);
  end;
end;

procedure TMain.AddWindow(AHandle: THandle; ATitle: string; AIcon: Hicon);
begin
  SetLength(Wins, Length(Wins) + 1);
  with Wins[High(Wins)] do begin
    Handle:=AHandle;
    Title:=ATitle;
    Icon:=AIcon;
  end;
end;

end.

