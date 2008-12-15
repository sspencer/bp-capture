require('Pathname')
require('tempfile')
#
# Take a interactive screenshot.
# 
class ScreenCapture

  # Reasonable number of samples, so we don't use too much memory
  @@DEFAULT_COUNTDOWN = 3

  # Constructor
  def initialize(args)
    # empty
  end

  #
  # All the user to interactively select an area of the screen to capture.  
  # A path is returned.
  #
  def interactive(bp, args)
    delay = args['delay'] || @@DEFAULT_COUNTDOWN
    delay = 1 if (delay < 1)
    delay = 20 if (delay > 20)

    Thread.new(bp, args['callback'], delay) do | bp,callback,delay |
      while delay > 0
        callback.invoke(delay) if callback
        delay -= 1
        sleep 1
      end
      callback.invoke(0) if callback
      tf = Tempfile.new("bpsc")
      path = tf.path
      tf.close # ok to close, we just want the filename (and file stays around long enough)
      if (system("screencapture -i #{path}"))
        bp.complete(Pathname.new(path))
      else
        bp.error('User canceled capture')
      end
    end
  end

end

rubyCoreletDefinition = {
  'class' => "ScreenCapture",
  'name'  => "ScreenCapture",
  'major_version' => 0,
  'minor_version' => 0,
  'micro_version' => 1,
  'documentation' => 
    'A service that allows the user to interactively take a screenshot of a portion of the screen. ' + 
    'This service is a proof of concept and only runs on Mac OS X (because on OS X, it just takes ' + 
    'a single command line script to capture the screen.  Windows, not so easy.)  A filehandle is returned ' +
    'which can be used with the FileAccess service.',

  'functions' =>
  [
    {
      'name' => 'interactive',
      'documentation' => "Takes a screenshot interactively.",
      'arguments' =>
      [
         {
            'name' => 'delay',
            'type' => 'integer',
            'required' => false,
            'documentation' => 'The time to delay before capturing the screen in seconds (default 3).'
          },
          {
            'name' => 'callback',
            'type' => 'callback',
            'required' => false,
            'documentation' => 'Countdown the number of seconds before the screen capture (called once per second).'
          }
      ]
    }
  ] 
}
