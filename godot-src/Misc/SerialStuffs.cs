using Godot;
using System;
using System.IO.Ports;

public partial class SerialStuffs : Node
{
	private ConfigFile config = new ConfigFile();
	[Signal]
	public delegate void RPMReaderEventHandler(double ink);
	SerialPort port = new SerialPort("/dev/ttyACM0");
	// Called when the node enters the scene tree for the first time.

	int currentRPM;
	public override void _Ready()
	{
		Error err = config.Load("user://pumpconfig.cfg");

		if (err != Error.Ok)
		{
			config.SetValue("Serial", "port", OS.GetName() == "Windows" ? "COM1" : "/dev/ttyACM0");
			config.Save("user://pumpconfig.cfg");
		}





		port = new SerialPort((String)config.GetValue("Serial", "port"));
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
