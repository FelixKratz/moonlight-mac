# moonlight-mac
Moonlight Client for macOS 10.13+ w/ HEVC support

This is an open source implementation of the NVIDIA Streaming Protocol for macOS and is based on moonlight-ios.

macOS supports native HEVC playback as of version 10.13, since the moonlight-chrome client lacks this feature I implemented it in a standalone, native macOS-Client. In addition to the HEVC support I hope to archive performance and latency improvements.

Status: early development, but already working

Usage: If you want to use this client in the current alpha alpha state you have will have to hardcode your settings into the ViewController in the following way:
-(void)alreadyPaired 
    _streamConfig = [[StreamConfiguration alloc] init];
    _streamConfig.bitRate = 10000; //Streaming Bitrate in kbps
    _streamConfig.frameRate = 30; //Streaming Framerate
    _streamConfig.height = 1080; //Streaming Resolution Height
    _streamConfig.width = 1920; // Streamung Resolution Width
    _streamConfig.host = _textFieldHost.stringValue;
    _streamConfig.streamingRemotely = 1; //This will toggle some improvements if you are connected over the Internet
    _streamConfig.appID = @"93751264"; //This is the appID of your desired app, this can be obtained from the host PC
    [self performSegueWithIdentifier:@"showStream" sender:self];
