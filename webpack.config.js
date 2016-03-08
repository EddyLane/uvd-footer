var path = require('path');
var webpack = require('webpack');

var env = process.env.MIX_ENV || 'dev';
var prod = env === 'prod';

var entry = './web/static/js/bundle.js';

var plugins = [
    new webpack.NoErrorsPlugin(),
    new webpack.DefinePlugin({
        __PROD__: prod
    })
];
var loaders = ['babel', 'elm-webpack', 'css-loader', 'url-loader'];
var publicPath = 'http://localhost:4001/';

if (prod) {
    plugins.push(new webpack.optimize.UglifyJsPlugin());
} else {
    plugins.push(new webpack.HotModuleReplacementPlugin());
    loaders.unshift('react-hot');
}

module.exports = {
    resolve: {
        extensions: ['', '.webpack.js', '.web.js', '.js', '.elm', '.css']
    },
    devtool: prod ? null : 'eval-sourcemaps',
    color: true,
    entry: prod ? entry : [
        'webpack-dev-server/client?' + publicPath,
        'webpack/hot/only-dev-server',
        entry
    ],
    output: {
        path: path.join(__dirname, './priv/static/js'),
        filename: 'bundle.js',
        publicPath: publicPath
    },
    plugins: plugins,
    module: {
        noParse: /\.elm$/,
        loaders: [,
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                loader: 'elm-webpack'
            },
            {
                test: /\.css$/,
                loader: "style-loader!css-loader"
            },
            {
                test: /\.scss$/,
                loaders: ['style', 'css', 'sass']
            },
            {
                test: /\.jsx?/,
                loader: 'babel-loader',
                exclude: /node_modules/
            },
            {
                test   : /\.(ttf|eot|svg|woff(2)?)(\?[a-z0-9]+)?$/,
                loader : 'file-loader'
            },
            {
                test: /\.(png|jpg|gif)$/,
                loader: 'url-loader?limit=8192'
            }
        ]
    }
};