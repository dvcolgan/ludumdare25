ig.module(
	'game.main'
)
.requires(
    'game.entities.player'
	'impact.entity'
	'impact.game'
	'impact.font'
    'game.levels.plains'
    'game.levels.villiage'
    'game.levels.castle'
    'game.levels.example'
)
.defines ->

    window.FullsizeBackdrop = ig.Image.extend
        resize: ->
            return null
        draw: ->
            if !@loaded then return
            ig.system.context.drawImage(@data, 0, 0)

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


        slideWin: new window.FullsizeBackdrop('media/win.png')
        slideWinTimer: new ig.Timer()

        slidesIntro: [
            new ig.Image('media/prolog-scene1.png')
            new ig.Image('media/prolog-scene2.png')
            new ig.Image('media/prolog-scene3.png')
            new ig.Image('media/prolog-scene4.png')
            new ig.Image('media/prolog-scene5.png')
            new ig.Image('media/prolog-scene6.png')
            new ig.Image('media/prolog-scene7.png')
            new ig.Image('media/prolog-scene8.png')
        ]
        currentIntroSlide: 0
        slideIntroTimer: new ig.Timer()

        slideHowtoplay: new window.FullsizeBackdrop('media/how-to-play.png')

        slidesLose: [
            new ig.Image('media/lose1.png')
            new ig.Image('media/lose2.png')
            new ig.Image('media/lose3.png')
            new ig.Image('media/lose4.png')
            new window.FullsizeBackdrop('media/lose5.png')
            new window.FullsizeBackdrop('media/lose6.png')
        ]
        currentLoseSlide: 0
        slideLoseTimer: new ig.Timer()

        loseTimer: new ig.Timer(60 * 2.5)
        
        init: ->
            ig.input.bind(ig.KEY.LEFT_ARROW, 'left')
            ig.input.bind(ig.KEY.RIGHT_ARROW, 'right')
            ig.input.bind(ig.KEY.UP_ARROW, 'up')
            ig.input.bind(ig.KEY.DOWN_ARROW, 'down')
            ig.input.bind(ig.KEY.SPACE, 'jump')
            ig.input.bind(ig.KEY.ENTER, 'pause')
            ig.input.bind(ig.KEY.ESC, 'escape')

            window.soundManager.stopAll()
            window.soundManager.play('intro-bgm')
            

        startGame: ->
            currentLevelNum = 0
            as = new ig.AnimationSheet('media/tiles.png', 16, 16)
            @backgroundAnims =
                'media/tiles.png':
                    26: new ig.Animation(as, 0.2, [26,26,27,26,26])

            @nextLevel()
            @loseTimer.reset()

        currentLevelNum: 0

        nextLevel: ->
            @currentLevelNum += 1

            if @currentLevelNum == 1
                window.soundManager.stopAll()
                window.soundManager.play('plains-bgm')
                @loadLevel(LevelPlains)
            else if @currentLevelNum == 2
                window.soundManager.stopAll()
                window.soundManager.play('villiage-bgm')
                @loadLevel(LevelVilliage)
            else if @currentLevelNum == 3
                window.soundManager.stopAll()
                window.soundManager.play('castle-bgm')
                @loadLevel(LevelCastle)
            else
                window.soundManager.stopAll()
                window.soundManager.play('win-bgm')
                @loadLevel({})
                @state = 'win'


            @player = ig.game.getEntityByName('player')
        
        update: ->

            if @state == 'title'
                if ig.input.pressed('jump')
                    @state = 'intro'
                    @slideIntroTimer.reset()

            else if @state == 'intro'
                if @slideIntroTimer.delta() < 3
                    @currentIntroSlide = 0
                else if @slideIntroTimer.delta() < 6
                    @currentIntroSlide = 1
                else if @slideIntroTimer.delta() < 9
                    @currentIntroSlide = 2
                else if @slideIntroTimer.delta() < 12
                    @currentIntroSlide = 3
                else if @slideIntroTimer.delta() < 15
                    @currentIntroSlide = 4
                else if @slideIntroTimer.delta() < 18
                    @currentIntroSlide = 5
                else if @slideIntroTimer.delta() < 21
                    @currentIntroSlide = 6
                else if @slideIntroTimer.delta() < 24
                    @currentIntroSlide = 7
                else if @slideIntroTimer.delta() < 27
                    @state = 'how-to-play'



                if ig.input.pressed('escape')
                    @state = 'how-to-play'

            else if @state == 'how-to-play'
                if ig.input.pressed('jump')
                    @state = 'game'
                    @currentLevelNum = 0
                    @startGame()

            else if @state == 'lose'
                if @slideLoseTimer.delta() < 3
                    @currentLoseSlide = 0
                else if @slideLoseTimer.delta() < 6
                    @currentLoseSlide = 1
                else if @slideLoseTimer.delta() < 9
                    @currentLoseSlide = 2
                else if @slideLoseTimer.delta() < 12
                    @currentLoseSlide = 3
                else if @slideLoseTimer.delta() < 18
                    @currentLoseSlide = 4
                else if @slideLoseTimer.delta() < 24
                    @currentLoseSlide = 5

                    if ig.input.pressed('jump')
                        @state = 'how-to-play'
                        window.soundManager.stopAll()
                        window.soundManager.play('intro-bgm')

                if ig.input.pressed('escape')
                    @state = 'how-to-play'
                    window.soundManager.stopAll()
                    window.soundManager.play('intro-bgm')

            else if @state == 'win'
                if @slideIntroTimer.delta() > 3
                    if ig.input.pressed('jump')
                        @state = 'title'

            else if @state == 'game'
                #if ig.input.pressed('pause')
                #    if not @paused
                #        @paused = true
                #        return
                #    else
                #        @paused = false

                #if @paused
                #    return

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

            else if @state == 'intro'
                @parent()
                @slidesIntro[@currentIntroSlide].draw(0, 0)

            else if @state == 'how-to-play'
                @parent()
                @slideHowtoplay.draw(0, 0)

            else if @state == 'game'
                levelWidth = ig.game.collisionMap.width * ig.game.collisionMap.tilesize
                ratio = @screen.x / (levelWidth - ig.system.width)

                @farthestBackground.draw(-(@farthestBackground.width - ig.system.width) * ratio, 0)
                @farBackground.draw(-(@farBackground.width - ig.system.width) * ratio, 0)


                @armies.draw(-@armies.width + (@armies.width - @armies.width * (-@loseTimer.delta() / (60*2.5))), 100)
                

                @nearBackground.draw(-(@nearBackground.width - ig.system.width) * ratio, 0)
                @parent()

                if -@loseTimer.delta() < 0
                    
                    @state = 'lose'
                    @loadLevel({})
                    @slideLoseTimer.reset()
                    window.soundManager.stopAll()
                    window.soundManager.play('lose-bgm')
                else
                    minutes = Math.floor(-@loseTimer.delta() / 60.0).toFixed(0)
                    seconds = Math.floor(-@loseTimer.delta() % 60).toFixed(0)
                    if seconds < 10
                        seconds = '0' + seconds
                    @font.draw("Armies arrive in: " + minutes + ':' + seconds, 80, 10)
                    #@font.draw("Vel.x: " + @player.vel.x, 10, 30)
                    #@font.draw("Wall Jump X Vel: " + @player.wallJumpXVel, 10, 40)
                    #@font.draw("Hugging Wall: " + @player.huggingWall, 10, 50)

            else if @state == 'lose'
                @parent()
                @slidesLose[@currentLoseSlide].draw(0, 0)
                
            if @state == 'win'
                @parent()
                @slideWin.draw(0, 0)


    if !ig.global.wm
        soundManager.setup {
            url: 'lib/soundmanager/swf/'
            flashVersion: 9
            useHighPerformance: true
            debugMode: false
            waitForWindowLoad: true
            onready: ->
                soundManager.createSound { multiShot: true, autoLoad: true, id: 'bell', url: 'media/bell.mp3', volume: 40 }
                soundManager.createSound { multiShot: true, autoLoad: true, id: 'dead', url: 'media/dead.mp3' }
                soundManager.createSound { multiShot: true, autoLoad: true, id: 'falling-from-sky', url: 'media/falling-from-sky.mp3', volume: 40}
                soundManager.createSound { multiShot: true, autoLoad: true, id: 'rolling-ground-hit', url: 'media/rolling-ground-hit.mp3' }
                soundManager.createSound { multiShot: true, autoLoad: true, id: 'jump', url: 'media/wall-jump.mp3', volume: 40}
                soundManager.createSound { multiShot: true, autoLoad: true, id: 'wall-jump', url: 'media/wall-jump.mp3' }
                
                soundManager.createSound {  volume: 30, autoLoad: true, loops: 10000, id: 'intro-bgm', url: 'musics/intro.mp3' }
                soundManager.createSound { volume: 30, autoLoad: true, loops: 10000, id: 'plains-bgm', url: 'musics/plains.mp3' }
                soundManager.createSound { volume: 30, autoLoad: true, loops: 10000, id: 'villiage-bgm', url: 'musics/villiage.mp3' }
                soundManager.createSound { volume: 30, autoLoad: true, loops: 10000, id: 'castle-bgm', url: 'musics/castle.mp3' }
                soundManager.createSound { volume: 30, autoLoad: true, loops: 10000, id: 'win-bgm', url: 'musics/win.mp3' }
                soundManager.createSound { volume: 30, autoLoad: true, loops: 10000, id: 'lose-bgm', url: 'musics/lose.mp3' }


                ig.main('#canvas', window.LD25Game, 60, 256, 240, 2)
            ontimeout: ->
                alert('Could not start Soundmanager.  Sounds will be disabled.')
                ig.main('#canvas', window.LD25Game, 60, 256, 240, 2)
        }
    else
        ig.main('#canvas', window.LD25Game, 60, 256, 240, 2)
