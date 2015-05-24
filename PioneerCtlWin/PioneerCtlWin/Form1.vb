Option Strict On
Imports System.Runtime.InteropServices

Public Class Form1

    Private Const KEYEVENTF_EXTENDEDKEY As Long = &H1
    Private Const KEYEVENTF_KEYUP As Long = &H2
    Private Const VK_LWIN As Byte = &H5B
    Private Declare Sub keybd_event Lib "user32" (ByVal bVk As Byte, _
    ByVal bScan As Byte, ByVal dwFlags As Long, ByVal dwExtraInfo As Long)

    Private Const WH_KEYBOARD_LL As Integer = 13
    Private Const WM_KEYUP As Integer = &H101
    Private Shared _proc As LowLevelKeyboardProc = AddressOf HookCallback
    Private Shared _hookID As IntPtr = IntPtr.Zero

    Public Declare Auto Function SetWindowsHookEx Lib "user32.dll" ( _
        ByVal idHook As Integer, ByVal lpfn As LowLevelKeyboardProc, _
        ByVal hMod As IntPtr, ByVal dwThreadId As UInteger) As IntPtr

    Public Declare Auto Function UnhookWindowsHookEx _
    Lib "user32.dll" (ByVal hhk As IntPtr) As IntPtr

    Public Declare Auto Function CallNextHookEx _
    Lib "user32.dll" (ByVal hhk As IntPtr, ByVal nCode As Integer, _
                      ByVal wParam As IntPtr, ByVal lParam As IntPtr) As IntPtr

    Public Declare Auto Function GetModuleHandle Lib "kernel32.dll" ( _
    ByVal lpModuleName As String) As IntPtr


    Private Shared Function SetHook( _
        ByVal proc As LowLevelKeyboardProc) As IntPtr

        Dim curProcess As Process = Process.GetCurrentProcess()
        Dim curModule As ProcessModule = curProcess.MainModule

        Return SetWindowsHookEx(WH_KEYBOARD_LL, proc, _
                GetModuleHandle(curModule.ModuleName), 0)

    End Function

    Public Delegate Function LowLevelKeyboardProc( _
        ByVal nCode As Integer, ByVal wParam As IntPtr, _
        ByVal lParam As IntPtr) As IntPtr

    Public Shared Function HookCallback( _
        ByVal nCode As Integer, _
        ByVal wParam As IntPtr, ByVal lParam As IntPtr) As IntPtr

        If nCode >= 0 And wParam = CType(WM_KEYUP, IntPtr) Then
            Dim vkCode As Keys = CType(Marshal.ReadInt32(lParam), Keys)
            Select Case vkCode
                Case Keys.MediaNextTrack
                    Form1.sendCmd(PCTCommand.ForwardTape)
                Case Keys.MediaPreviousTrack
                    Form1.sendCmd(PCTCommand.RewindTape)
                Case Keys.Play
                    Form1.sendCmd(PCTCommand.PlayTape)
                Case Keys.MediaPlayPause
                    If Form1._playing Then
                        If Form1.chkStops.Checked Then
                            Form1.sendCmd(PCTCommand.StopTape)
                        Else
                            Form1.sendCmd(PCTCommand.PauseTape)
                        End If
                    Else
                        Form1.sendCmd(PCTCommand.PlayTape)
                    End If
                Case Keys.Pause
                    If Form1.chkStops.Checked Then
                        Form1.sendCmd(PCTCommand.StopTape)
                    Else
                        Form1.sendCmd(PCTCommand.PauseTape)
                    End If

            End Select
        End If

        Return CallNextHookEx(_hookID, nCode, wParam, lParam)
    End Function

    Private Sub Form1_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        _hookID = SetHook(_proc)
        For Each port As String In IO.Ports.SerialPort.GetPortNames
            ComboBox1.Items.Add(port)
        Next
        
    End Sub

    Private Sub Form1_FormClosed(ByVal sender As Object, ByVal e As System.Windows.Forms.FormClosedEventArgs) Handles Me.FormClosed
        UnhookWindowsHookEx(_hookID)
    End Sub
    Private Sub Form1_Resize(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Resize
        Try
            If Me.WindowState = FormWindowState.Minimized Then
                Me.WindowState = FormWindowState.Minimized
                taskbarIcon.Visible = True
                Me.Hide()
            End If
        Catch ex As Exception
            MsgBox(ex.Message)
        End Try
    End Sub

    Enum PCTCommand
        PowerDeck
        StopTape
        RewindTape
        ForwardTape
        PlayTape
        PauseTape
        RecordTape
    End Enum
    Dim _playing As Boolean = False
    Sub sendCmd(ByVal command As PCTCommand)
        If ComboBox1.Text <> SerialPort1.PortName Then
            SerialPort1.Close()
        End If
        If Not SerialPort1.IsOpen Then
            SerialPort1.PortName = ComboBox1.Text
            Try
                SerialPort1.Open()
            Catch ex As Exception
                MsgBox(String.Format("Error opening {0}: {1}", SerialPort1.PortName, ex.Message), MsgBoxStyle.Critical, "Pioneer Tape Deck")
                Return
            End Try
        End If
        Select Case command
            Case PCTCommand.PowerDeck
                SerialPort1.Write("OO")
                If _playing Then _playing = False
            Case PCTCommand.PlayTape
                SerialPort1.Write("PP")
                _playing = True
            Case PCTCommand.PauseTape
                SerialPort1.Write("HH")
                If _playing Then _playing = False
            Case PCTCommand.StopTape
                SerialPort1.Write("SS")
                _playing = False
            Case PCTCommand.RewindTape
                SerialPort1.Write("BB")
            Case PCTCommand.ForwardTape
                SerialPort1.Write("FF")
            Case PCTCommand.RecordTape
                SerialPort1.Write("RR")
        End Select
    End Sub

    Private Sub ExitToolStripMenuItem_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ExitToolStripMenuItem.Click
        End
    End Sub



    Private Sub Button2_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button2.Click, PowerToolStripMenuItem.Click
        sendCmd(PCTCommand.PowerDeck)
    End Sub

    Private Sub btnStop_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnStop.Click, StopToolStripMenuItem.Click
        sendCmd(PCTCommand.StopTape)
    End Sub

    Private Sub btnRew_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnRew.Click, RewindToolStripMenuItem.Click
        sendCmd(PCTCommand.RewindTape)
    End Sub

    Private Sub btnPlay_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnPlay.Click, PlayToolStripMenuItem.Click
        sendCmd(PCTCommand.PlayTape)
    End Sub

    Private Sub btnFwd_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnFwd.Click, ForwardToolStripMenuItem.Click
        sendCmd(PCTCommand.ForwardTape)
    End Sub

    Private Sub btnPau_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnPau.Click, PauseToolStripMenuItem.Click
        sendCmd(PCTCommand.PauseTape)
    End Sub

    Private Sub btnRec_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnRec.Click, RecordToolStripMenuItem.Click
        sendCmd(PCTCommand.RecordTape)
    End Sub


    Private Sub ShowToolStripMenuItem_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ShowToolStripMenuItem.Click
        Me.Show()
        Me.WindowState = FormWindowState.Normal
        taskbarIcon.Visible = False
    End Sub

    Private Sub taskbarIcon_MouseDoubleClick(ByVal sender As System.Object, ByVal e As System.Windows.Forms.MouseEventArgs) Handles taskbarIcon.MouseDoubleClick
        Me.Show()
        Me.WindowState = FormWindowState.Normal
        taskbarIcon.Visible = False
    End Sub

    Private Sub Form1_Shown(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Shown
        If My.Settings.hideLaunch Then
            Me.WindowState = FormWindowState.Minimized
            taskbarIcon.Visible = True
            Me.Hide()
        End If
    End Sub
End Class