#if web
import openfl.net.NetConnection;
import openfl.net.NetStream;
import openfl.events.NetStatusEvent;
import openfl.media.Video;
#else
import vlc.MP4Handler;
#end
import flixel.FlxBasic;
import flixel.FlxG;

class FlxVideo extends FlxBasic {
	#if VIDEOS_ALLOWED
	public var finishCallback:Void->Void = null;
	
	#if !web
	public static var video:MP4Handler;
	#end

	public function new(name:String) {
		super();

		#if web
		var player:Video = new Video();
		player.x = 0;
		player.y = 0;
		FlxG.addChildBelowMouse(player);
		var netConnect = new NetConnection();
		netConnect.connect(null);
		var netStream = new NetStream(netConnect);
		netStream.client = {
			onMetaData: function() {
				player.attachNetStream(netStream);
				player.width = FlxG.width;
				player.height = FlxG.height;
			}
		};
		netConnect.addEventListener(NetStatusEvent.NET_STATUS, function(event:NetStatusEvent) {
			if(event.info.code == "NetStream.Play.Complete") {
				netStream.dispose();
				if(FlxG.game.contains(player)) FlxG.game.removeChild(player);

				if(finishCallback != null) finishCallback();
			}
		});
		netStream.play(name);

		#else

		video = new MP4Handler();
		video.finishCallback = function()
		{
				if (finishCallback != null){
			        finishCallback();
		        }
		}
		video.playVideo(name);
		#end
	}
	#end
}