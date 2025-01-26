using Godot;
using System;
using System.ComponentModel;
using System.IO.Ports;
using System.Threading;




public partial class SerialStuffs : Node
{

	[Signal]
	public delegate void RPMReaderEventHandler(double ink);
	SerialPort port = new SerialPort("/dev/ttyACM0");
	// Called when the node enters the scene tree for the first time.

	int currentRPM;
	public override void _Ready()
	{
		port.BaudRate = 9600;
		port.Parity = Parity.None;
		port.StopBits = StopBits.One;
		port.DataBits = 8;
		port.Handshake = Handshake.None;
		port.DtrEnable = true;
		port.RtsEnable = true;
		port.ReadTimeout = 0;
		port.Open();
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		try
		{

			var RPM = port.ReadLine();
			GD.Print($"RPM: {RPM}");
			currentRPM = Convert.ToInt32(RPM);
			EmitSignal(SignalName.RPMReader, currentRPM);
		}
		catch (TimeoutException) { }
	}

	public override void _ExitTree()
	{
		port.Close();
		base._ExitTree();
	}

	public void OnTimerTimeout()
	{
		return;
	}
}
