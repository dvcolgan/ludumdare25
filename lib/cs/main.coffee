ig.module(
	'game.main'
)
.requires(
    'game.entities.player'
	'impact.entity'
	'impact.game'
	'impact.font'
    'game.levels.plains'
)
.defines ->

    window.sounds = {}

    window.LD25Game = ig.Game.extend
        
        font: new ig.Font('media/04b03.font.png')
        gravity: 600
        paused: false
        clearColor: null

        state: 'title'
        titleImage: new ig.Image('media/box-cover.png')
        farthestBackground: new ig.Image('media/farthest-background.png')
        farBackground: new ig.Image('media/far-background.png')
        nearBackground: new ig.Image('media/near-background.png')
        armies: new ig.Image('media/advancing-army.png')

        loseTimer: new ig.Timer(60 * 5)
        
        init: ->
            ig.input.bind(ig.KEY.LEFT_ARROW, 'left')
            ig.input.bind(ig.KEY.RIGHT_ARROW, 'right')
            ig.input.bind(ig.KEY.UP_ARROW, 'up')
            ig.input.bind(ig.KEY.DOWN_ARROW, 'down')
            ig.input.bind(ig.KEY.SPACE, 'jump')
            ig.input.bind(ig.KEY.ENTER, 'pause')
            

        startGame: ->
            @currentLevel = @loadLevel(LevelPlains)
            @player = ig.game.getEntityByName('player')
            #window.sounds['sound'].play()
            @loseTimer.reset()

        nextLevel: ->
            alert('There are no more levels, so I guess you win for now.')
        
        update: ->

            if @state == 'title'

                if ig.input.pressed('jump')
                    @state = 'game'
                    @startGame()

            if @state == 'game'
                if ig.input.pressed('pause')
                    if not @paused
                        @paused = true
                        return
                    else
                        @paused = false

                if @paused
                    return

                # screen follows the player
                if @player
                    @screen.x = @player.pos.x - ig.system.width/8 * 3
                    @screen.y = @player.pos.y - ig.system.height/2
                    if @screen.x < 0 then @screen.x = 0
                    if @screen.y < 0 then @screen.y = 0

                    colMap = ig.game.collisionMap
                    levelWidth = colMap.width * colMap.tilesize
                    levelHeight = colMap.height * colMap.tilesize

                    if @screen.x > levelWidth - ig.system.width then @screen.x = levelWidth - ig.system.width
                    if @screen.y > levelHeight - ig.system.height  then @screen.y = levelHeight - ig.system.height

            @parent()

        draw: ->


            if @state == 'title'
                @parent()
                @titleImage.draw(0, 0)

            if @state == 'game'
                levelWidth = ig.game.collisionMap.width * ig.game.collisionMap.tilesize
                ratio = @screen.x / (levelWidth - ig.system.width)

                @farthestBackground.draw(-(@farthestBackground.width - ig.system.width) * ratio, 0)
                @farBackground.draw(-(@farBackground.width - ig.system.width) * ratio, 0)


                @armies.draw(-@armies.width + (@armies.width - @armies.width * (-@loseTimer.delta() / (60*5))), 100)
                

                @nearBackground.draw(-(@nearBackground.width - ig.system.width) * ratio, 0)
                @parent()

                if -@loseTimer.delta < 0
                    alert('The king and everyone in the castle died.  Now YOU are the villain.')
                    alert('Directed by M Night Shamalan')
                else
                    minutes = Math.floor(-@loseTimer.delta() / 60.0).toFixed(0)
                    seconds = Math.floor(-@loseTimer.delta() % 60).toFixed(0)
                    if seconds < 10
                        seconds = '0' + seconds
                    @font.draw("Armies arrive in: " + minutes + ':' + seconds, 80, 10)

                


    if !ig.global.wm
        soundManager.setup {
            url: 'lib/soundmanager/swf/'
            onready: ->
                window.sounds =
                    'sound': soundManager.createSound { id: 'sound', url: 'media/sound.wav' }

                ig.main('#canvas', window.LD25Game, 60, 256, 240, 2)
            ontimeout: ->
                alert('Could not start Soundmanager.  Is Flash blocked?')
        }
    else
        ig.main('#canvas', window.LD25Game, 30, 256, 240, 2)
