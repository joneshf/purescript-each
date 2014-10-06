'use strict'

var gulp        = require('gulp')
  , purescript  = require('gulp-purescript')
  , run         = require('gulp-run')
  , runSequence = require('run-sequence')
  ;

var paths =
    { src: 'src/**/*.purs'
    , bowerSrc: [ 'bower_components/purescript-*/src/**/*.purs'
                ]
    , dest: ''
    , docs: { 'Control.Each': { dest: 'src/Control/README.md'
                              , src: 'src/Control/Each.purs'
                              }
            }
    , test: 'test/**/*.purs'
    };

var options =
    { test: { main: 'Test.Control.Each'
            }
    };

var compile = function(compiler, src, opts) {
    var psc = compiler(opts);
    psc.on('error', function(e) {
        console.error(e.message);
        psc.end();
    });
    return gulp.src(src.concat(paths.bowerSrc))
        .pipe(psc)
        .pipe(gulp.dest(paths.dest));
};

function docs (target) {
    return function() {
        var docgen = purescript.docgen();
        docgen.on('error', function(e) {
            console.error(e.message);
            docgen.end();
        });
        return gulp.src(paths.docs[target].src)
            .pipe(docgen)
            .pipe(gulp.dest(paths.docs[target].dest));
    }
}

gulp.task('make', function() {
    return compile(purescript.pscMake, [paths.src], {});
});

gulp.task('browser', function() {
    return compile(purescript.psc, [paths.src], {});
});

gulp.task('docs-Control.Each', docs('Control.Each'));

gulp.task('docs', ['docs-Control.Each']);

gulp.task('watch-browser', function() {
    gulp.watch(paths.src, function() {runSequence('browser', 'docs')});
});

gulp.task('watch-make', function() {
    gulp.watch(paths.src, function() {runSequence('make', 'docs')});
});

gulp.task('test', function() {
    return compile(purescript.psc, [paths.src, paths.test], options.test)
        .pipe(run('node').exec());
});

gulp.task('default', function() {runSequence('make', 'docs')});
