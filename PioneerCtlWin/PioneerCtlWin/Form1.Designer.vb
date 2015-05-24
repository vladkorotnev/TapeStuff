<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class Form1
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.components = New System.ComponentModel.Container()
        Dim resources As System.ComponentModel.ComponentResourceManager = New System.ComponentModel.ComponentResourceManager(GetType(Form1))
        Me.btnPlay = New System.Windows.Forms.Button()
        Me.SerialPort1 = New System.IO.Ports.SerialPort(Me.components)
        Me.btnFwd = New System.Windows.Forms.Button()
        Me.btnRew = New System.Windows.Forms.Button()
        Me.btnRec = New System.Windows.Forms.Button()
        Me.btnPau = New System.Windows.Forms.Button()
        Me.btnStop = New System.Windows.Forms.Button()
        Me.Button2 = New System.Windows.Forms.Button()
        Me.taskbarIcon = New System.Windows.Forms.NotifyIcon(Me.components)
        Me.ContextMenuStrip1 = New System.Windows.Forms.ContextMenuStrip(Me.components)
        Me.ControlToolStripMenuItem = New System.Windows.Forms.ToolStripMenuItem()
        Me.PlayToolStripMenuItem = New System.Windows.Forms.ToolStripMenuItem()
        Me.PauseToolStripMenuItem = New System.Windows.Forms.ToolStripMenuItem()
        Me.StopToolStripMenuItem = New System.Windows.Forms.ToolStripMenuItem()
        Me.ToolStripMenuItem1 = New System.Windows.Forms.ToolStripSeparator()
        Me.RewindToolStripMenuItem = New System.Windows.Forms.ToolStripMenuItem()
        Me.ForwardToolStripMenuItem = New System.Windows.Forms.ToolStripMenuItem()
        Me.ToolStripMenuItem2 = New System.Windows.Forms.ToolStripSeparator()
        Me.PowerToolStripMenuItem = New System.Windows.Forms.ToolStripMenuItem()
        Me.RecordToolStripMenuItem = New System.Windows.Forms.ToolStripMenuItem()
        Me.ToolStripMenuItem3 = New System.Windows.Forms.ToolStripSeparator()
        Me.ShowToolStripMenuItem = New System.Windows.Forms.ToolStripMenuItem()
        Me.ExitToolStripMenuItem = New System.Windows.Forms.ToolStripMenuItem()
        Me.chkStops = New System.Windows.Forms.CheckBox()
        Me.chkHide = New System.Windows.Forms.CheckBox()
        Me.ComboBox1 = New System.Windows.Forms.ComboBox()
        Me.ContextMenuStrip1.SuspendLayout()
        Me.SuspendLayout()
        '
        'btnPlay
        '
        Me.btnPlay.Location = New System.Drawing.Point(168, 39)
        Me.btnPlay.Name = "btnPlay"
        Me.btnPlay.Size = New System.Drawing.Size(49, 23)
        Me.btnPlay.TabIndex = 0
        Me.btnPlay.Text = "Play"
        Me.btnPlay.UseVisualStyleBackColor = True
        '
        'SerialPort1
        '
        Me.SerialPort1.BaudRate = 38400
        '
        'btnFwd
        '
        Me.btnFwd.Location = New System.Drawing.Point(223, 39)
        Me.btnFwd.Name = "btnFwd"
        Me.btnFwd.Size = New System.Drawing.Size(49, 23)
        Me.btnFwd.TabIndex = 2
        Me.btnFwd.Text = "Fwd"
        Me.btnFwd.UseVisualStyleBackColor = True
        '
        'btnRew
        '
        Me.btnRew.Location = New System.Drawing.Point(113, 39)
        Me.btnRew.Name = "btnRew"
        Me.btnRew.Size = New System.Drawing.Size(49, 23)
        Me.btnRew.TabIndex = 3
        Me.btnRew.Text = "Rew"
        Me.btnRew.UseVisualStyleBackColor = True
        '
        'btnRec
        '
        Me.btnRec.Location = New System.Drawing.Point(113, 68)
        Me.btnRec.Name = "btnRec"
        Me.btnRec.Size = New System.Drawing.Size(49, 23)
        Me.btnRec.TabIndex = 6
        Me.btnRec.Text = "Rec"
        Me.btnRec.UseVisualStyleBackColor = True
        '
        'btnPau
        '
        Me.btnPau.Location = New System.Drawing.Point(168, 68)
        Me.btnPau.Name = "btnPau"
        Me.btnPau.Size = New System.Drawing.Size(104, 23)
        Me.btnPau.TabIndex = 4
        Me.btnPau.Text = "Pause"
        Me.btnPau.UseVisualStyleBackColor = True
        '
        'btnStop
        '
        Me.btnStop.Location = New System.Drawing.Point(51, 39)
        Me.btnStop.Name = "btnStop"
        Me.btnStop.Size = New System.Drawing.Size(56, 52)
        Me.btnStop.TabIndex = 7
        Me.btnStop.Text = "Stop"
        Me.btnStop.UseVisualStyleBackColor = True
        '
        'Button2
        '
        Me.Button2.Location = New System.Drawing.Point(12, 67)
        Me.Button2.Name = "Button2"
        Me.Button2.Size = New System.Drawing.Size(33, 23)
        Me.Button2.TabIndex = 8
        Me.Button2.Text = "Pwr"
        Me.Button2.UseVisualStyleBackColor = True
        '
        'taskbarIcon
        '
        Me.taskbarIcon.ContextMenuStrip = Me.ContextMenuStrip1
        Me.taskbarIcon.Icon = CType(resources.GetObject("taskbarIcon.Icon"), System.Drawing.Icon)
        Me.taskbarIcon.Text = "Pioneer Tape Recorder"
        '
        'ContextMenuStrip1
        '
        Me.ContextMenuStrip1.Items.AddRange(New System.Windows.Forms.ToolStripItem() {Me.ControlToolStripMenuItem, Me.ToolStripMenuItem3, Me.ShowToolStripMenuItem, Me.ExitToolStripMenuItem})
        Me.ContextMenuStrip1.Name = "ContextMenuStrip1"
        Me.ContextMenuStrip1.Size = New System.Drawing.Size(115, 76)
        '
        'ControlToolStripMenuItem
        '
        Me.ControlToolStripMenuItem.DropDownItems.AddRange(New System.Windows.Forms.ToolStripItem() {Me.PlayToolStripMenuItem, Me.PauseToolStripMenuItem, Me.StopToolStripMenuItem, Me.ToolStripMenuItem1, Me.RewindToolStripMenuItem, Me.ForwardToolStripMenuItem, Me.ToolStripMenuItem2, Me.PowerToolStripMenuItem, Me.RecordToolStripMenuItem})
        Me.ControlToolStripMenuItem.Name = "ControlToolStripMenuItem"
        Me.ControlToolStripMenuItem.Size = New System.Drawing.Size(114, 22)
        Me.ControlToolStripMenuItem.Text = "Control"
        '
        'PlayToolStripMenuItem
        '
        Me.PlayToolStripMenuItem.Name = "PlayToolStripMenuItem"
        Me.PlayToolStripMenuItem.Size = New System.Drawing.Size(117, 22)
        Me.PlayToolStripMenuItem.Text = "Play"
        '
        'PauseToolStripMenuItem
        '
        Me.PauseToolStripMenuItem.Name = "PauseToolStripMenuItem"
        Me.PauseToolStripMenuItem.Size = New System.Drawing.Size(117, 22)
        Me.PauseToolStripMenuItem.Text = "Pause"
        '
        'StopToolStripMenuItem
        '
        Me.StopToolStripMenuItem.Name = "StopToolStripMenuItem"
        Me.StopToolStripMenuItem.Size = New System.Drawing.Size(117, 22)
        Me.StopToolStripMenuItem.Text = "Stop"
        '
        'ToolStripMenuItem1
        '
        Me.ToolStripMenuItem1.Name = "ToolStripMenuItem1"
        Me.ToolStripMenuItem1.Size = New System.Drawing.Size(114, 6)
        '
        'RewindToolStripMenuItem
        '
        Me.RewindToolStripMenuItem.Name = "RewindToolStripMenuItem"
        Me.RewindToolStripMenuItem.Size = New System.Drawing.Size(117, 22)
        Me.RewindToolStripMenuItem.Text = "Rewind"
        '
        'ForwardToolStripMenuItem
        '
        Me.ForwardToolStripMenuItem.Name = "ForwardToolStripMenuItem"
        Me.ForwardToolStripMenuItem.Size = New System.Drawing.Size(117, 22)
        Me.ForwardToolStripMenuItem.Text = "Forward"
        '
        'ToolStripMenuItem2
        '
        Me.ToolStripMenuItem2.Name = "ToolStripMenuItem2"
        Me.ToolStripMenuItem2.Size = New System.Drawing.Size(114, 6)
        '
        'PowerToolStripMenuItem
        '
        Me.PowerToolStripMenuItem.Name = "PowerToolStripMenuItem"
        Me.PowerToolStripMenuItem.Size = New System.Drawing.Size(117, 22)
        Me.PowerToolStripMenuItem.Text = "Power"
        '
        'RecordToolStripMenuItem
        '
        Me.RecordToolStripMenuItem.Name = "RecordToolStripMenuItem"
        Me.RecordToolStripMenuItem.Size = New System.Drawing.Size(117, 22)
        Me.RecordToolStripMenuItem.Text = "Record"
        '
        'ToolStripMenuItem3
        '
        Me.ToolStripMenuItem3.Name = "ToolStripMenuItem3"
        Me.ToolStripMenuItem3.Size = New System.Drawing.Size(111, 6)
        '
        'ShowToolStripMenuItem
        '
        Me.ShowToolStripMenuItem.Name = "ShowToolStripMenuItem"
        Me.ShowToolStripMenuItem.Size = New System.Drawing.Size(114, 22)
        Me.ShowToolStripMenuItem.Text = "Show"
        '
        'ExitToolStripMenuItem
        '
        Me.ExitToolStripMenuItem.Name = "ExitToolStripMenuItem"
        Me.ExitToolStripMenuItem.Size = New System.Drawing.Size(114, 22)
        Me.ExitToolStripMenuItem.Text = "Exit"
        '
        'chkStops
        '
        Me.chkStops.AutoSize = True
        Me.chkStops.Checked = Global.PioneerCtlWin.My.MySettings.Default.mediakeyStops
        Me.chkStops.DataBindings.Add(New System.Windows.Forms.Binding("Checked", Global.PioneerCtlWin.My.MySettings.Default, "mediakeyStops", True, System.Windows.Forms.DataSourceUpdateMode.OnPropertyChanged))
        Me.chkStops.Location = New System.Drawing.Point(107, 97)
        Me.chkStops.Name = "chkStops"
        Me.chkStops.Size = New System.Drawing.Size(176, 17)
        Me.chkStops.TabIndex = 11
        Me.chkStops.Text = "Mediakey stop instead of pause"
        Me.chkStops.UseVisualStyleBackColor = True
        '
        'chkHide
        '
        Me.chkHide.AutoSize = True
        Me.chkHide.Checked = Global.PioneerCtlWin.My.MySettings.Default.hideLaunch
        Me.chkHide.DataBindings.Add(New System.Windows.Forms.Binding("Checked", Global.PioneerCtlWin.My.MySettings.Default, "hideLaunch", True, System.Windows.Forms.DataSourceUpdateMode.OnPropertyChanged))
        Me.chkHide.Location = New System.Drawing.Point(12, 97)
        Me.chkHide.Name = "chkHide"
        Me.chkHide.Size = New System.Drawing.Size(98, 17)
        Me.chkHide.TabIndex = 10
        Me.chkHide.Text = "Hide on launch"
        Me.chkHide.UseVisualStyleBackColor = True
        '
        'ComboBox1
        '
        Me.ComboBox1.DataBindings.Add(New System.Windows.Forms.Binding("Text", Global.PioneerCtlWin.My.MySettings.Default, "Port", True, System.Windows.Forms.DataSourceUpdateMode.OnPropertyChanged))
        Me.ComboBox1.FormattingEnabled = True
        Me.ComboBox1.Location = New System.Drawing.Point(12, 12)
        Me.ComboBox1.Name = "ComboBox1"
        Me.ComboBox1.Size = New System.Drawing.Size(260, 21)
        Me.ComboBox1.TabIndex = 1
        Me.ComboBox1.Text = Global.PioneerCtlWin.My.MySettings.Default.selectedCOM
        '
        'Form1
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(284, 123)
        Me.Controls.Add(Me.chkStops)
        Me.Controls.Add(Me.chkHide)
        Me.Controls.Add(Me.Button2)
        Me.Controls.Add(Me.btnStop)
        Me.Controls.Add(Me.btnRec)
        Me.Controls.Add(Me.btnPau)
        Me.Controls.Add(Me.btnRew)
        Me.Controls.Add(Me.btnFwd)
        Me.Controls.Add(Me.ComboBox1)
        Me.Controls.Add(Me.btnPlay)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle
        Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
        Me.MaximizeBox = False
        Me.Name = "Form1"
        Me.Text = "PioneerCtlWin"
        Me.ContextMenuStrip1.ResumeLayout(False)
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents btnPlay As System.Windows.Forms.Button
    Friend WithEvents SerialPort1 As System.IO.Ports.SerialPort
    Friend WithEvents ComboBox1 As System.Windows.Forms.ComboBox
    Friend WithEvents btnFwd As System.Windows.Forms.Button
    Friend WithEvents btnRew As System.Windows.Forms.Button
    Friend WithEvents btnRec As System.Windows.Forms.Button
    Friend WithEvents btnPau As System.Windows.Forms.Button
    Friend WithEvents btnStop As System.Windows.Forms.Button
    Friend WithEvents Button2 As System.Windows.Forms.Button
    Friend WithEvents taskbarIcon As System.Windows.Forms.NotifyIcon
    Friend WithEvents ContextMenuStrip1 As System.Windows.Forms.ContextMenuStrip
    Friend WithEvents ControlToolStripMenuItem As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents PlayToolStripMenuItem As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents PauseToolStripMenuItem As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents ToolStripMenuItem1 As System.Windows.Forms.ToolStripSeparator
    Friend WithEvents RewindToolStripMenuItem As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents ForwardToolStripMenuItem As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents ToolStripMenuItem2 As System.Windows.Forms.ToolStripSeparator
    Friend WithEvents PowerToolStripMenuItem As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents RecordToolStripMenuItem As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents ToolStripMenuItem3 As System.Windows.Forms.ToolStripSeparator
    Friend WithEvents ShowToolStripMenuItem As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents ExitToolStripMenuItem As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents chkHide As System.Windows.Forms.CheckBox
    Friend WithEvents StopToolStripMenuItem As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents chkStops As System.Windows.Forms.CheckBox

End Class
