unit MyProcessLauncher; //http://wiki.freepascal.org/Executing_External_Programs#TProcess

{$mode objfpc}{$H+}
interface

uses
  Classes, SysUtils, Process;

const
  BUF_SIZE = 2048;


function RunProcess(programName: String; params: array of String) : Integer;

implementation

var
  AProcess : TProcess;
  OutputStream : TStream;
  BytesRead : longint;
  Buffer : array[1..BUF_SIZE] of byte;

function RunProcess(programName: String; params: array of String) : Integer;
begin

  // Set up the process; as an example a recursive directory search is used
  // because that will usually result in a lot of data.
  AProcess := TProcess.Create(nil);

  // The commands for Windows and *nix are different hence the $IFDEFs
  {$IFDEF Windows}
    // In Windows the dir command cannot be used directly because it's a build-in
    // shell command. Therefore cmd.exe and the extra parameters are needed.
    AProcess.Executable := programName;
    AProcess.Parameters.Add('/c');
    AProcess.Parameters.Add('dir /s c:\windows');
  {$ENDIF Windows}

  {$IFDEF Unix}
    AProcess.Executable := '/bin/ls';
    AProcess.Parameters.Add('--recursive');
    AProcess.Parameters.Add('--all');
    AProcess.Parameters.Add('-l');
  {$ENDIF Unix}

  // Process option poUsePipes has to be used so the output can be captured.
  // Process option poWaitOnExit can not be used because that would block
  // this program, preventing it from reading the output data of the process.
  AProcess.Options := [poUsePipes];

  // Start the process (run the dir/ls command)
  AProcess.Execute;

  // Create a stream object to store the generated output in. This could
  // also be a file stream to directly save the output to disk.
  OutputStream := TMemoryStream.Create;

  // All generated output from AProcess is read in a loop until no more data is available
  repeat
    // Get the new data from the process to a maximum of the buffer size that was allocated.
    // Note that all read(...) calls will block except for the last one, which returns 0 (zero).
    BytesRead := AProcess.Output.Read(Buffer, BUF_SIZE);

    // Add the bytes that were read to the stream for later usage
    OutputStream.Write(Buffer, BytesRead)

  until BytesRead = 0;  // Stop if no more data is available

  // The process has finished so it can be cleaned up
  AProcess.Free;

  // Or the data can be shown on screen
  with TStringList.Create do
  begin
    OutputStream.Position := 0; // Required to make sure all data is copied from the start
    LoadFromStream(OutputStream);
    writeln(Text);
    writeln('--- Number of lines = ', Count, '----');
    Free
  end;

  // Clean up
  OutputStream.Free;

  RunProcess := 0;


end;


end.

