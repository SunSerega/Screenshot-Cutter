{$reference System.Windows.Forms.dll}
{$reference System.Drawing.dll}
{$apptype windows}

uses System.Windows.Forms;
uses System.Drawing;
uses System.Threading;

function MakeScreenShot: Bitmap;
begin
  var sz := Screen.PrimaryScreen.Bounds.Size;
  Result := new Bitmap(sz.Width,sz.Height);
  Graphics.FromImage(Result).CopyFromScreen(0,0,0,0,sz);
end;

begin
  var screenshot := MakeScreenShot;
  
  var MainForm := new Form;
  MainForm.FormBorderStyle := FormBorderStyle.None;
  MainForm.WindowState := FormWindowState.Minimized;
  MainForm.BackColor := Color.FromArgb(128,128,128);
  MainForm.Opacity := 1/255;
  MainForm.Closing += (o,e)->Halt();
  MainForm.LostFocus += (o,e)->Halt();
  
  var SelectRectForm := new Form;
  SelectRectForm.AddOwnedForm(MainForm);
  SelectRectForm.AllowTransparency := true;
  SelectRectForm.TransparencyKey := Color.Black;
  SelectRectForm.BackColor := Color.Black;
  SelectRectForm.FormBorderStyle := FormBorderStyle.None;
  SelectRectForm.WindowState := FormWindowState.Minimized;
  SelectRectForm.Shown += (o,e)->
  begin
    MainForm.WindowState := FormWindowState.Maximized;
    SelectRectForm.WindowState := FormWindowState.Maximized;
  end;
  SelectRectForm.Closing += (o,e)->Halt();
  
  var SelectRect := new PictureBox;
  SelectRectForm.Controls.Add(SelectRect);
  SelectRect.Dock := DockStyle.Fill;
  
  var p1: Point?;
  var p2: Point?;
  
  MainForm.MouseDown += (o,e)->
  begin
    if e.Button = MouseButtons.Left then
    begin
      p1 := e.Location;
      p2 := e.Location;
    end else
      p1 := nil;
    SelectRect.Invalidate;
  end;
  
  MainForm.MouseMove += (o,e)->
  begin
    if p1=nil then exit;
    p2 := e.Location;
    SelectRect.Invalidate;
  end;
  
  MainForm.MouseUp += (o,e)->
  begin
    if p1=nil then exit;
    p2 := e.Location;
    
    if e.Button = MouseButtons.Left then
    begin
      var x1 := p1.Value.X;
      var y1 := p1.Value.Y;
      var x2 := p2.Value.X;
      var y2 := p2.Value.Y;
      
      if (Abs(x1-x2)>5) and (Abs(y1-y2)>5) then
      begin
        if x1>x2 then Swap(x1,x2);
        if y1>y2 then Swap(y1,y2);
        
        var res := new Bitmap(x2-x1,y2-y1);
        Graphics.FromImage(res).DrawImageUnscaledAndClipped(screenshot, new Rectangle(-x1,-y1,screenshot.Width,screenshot.Height));
        Clipboard.SetImage(res);
        Halt;
      end;
    end;
    
    p1 := nil;
    SelectRect.Invalidate;
  end;
  
  MainForm.KeyDown += (o,e)->
  begin
    case e.KeyCode of
      
      Keys.Escape:
      begin
        if p1=nil then
          Halt else
        begin
          p1 := nil;
          SelectRect.Invalidate;
        end;
      end;
      
    end;
  end;
  
  SelectRect.Paint += (o,e)->
  begin
    var gr := e.Graphics;
    
    var lp1 := p1;
    var lp2 := p2;
    
    if (lp1<>nil) and (lp2<>nil) then
    begin
      var x1 := lp1.Value.X;
      var y1 := lp1.Value.Y;
      var x2 := lp2.Value.X;
      var y2 := lp2.Value.Y;
      
      if (Abs(x1-x2)>5) and (Abs(y1-y2)>5) then
      begin
        if x1>x2 then Swap(x1,x2);
        if y1>y2 then Swap(y1,y2);
        gr.DrawRectangle(new Pen(Color.Red, 3), x1,y1, x2-x1,y2-y1);
      end;
      
    end;
    
  end;
  
  SelectRectForm.Shown += (o,e)->
  begin
    var thr := new Thread(()->Application.Run(MainForm));
    thr.ApartmentState := ApartmentState.STA;
    thr.Start;
  end;
  Application.Run(SelectRectForm);
end.