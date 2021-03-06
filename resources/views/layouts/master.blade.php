<!DOCTYPE html>
<html lang="en" ng-app="app">
<head>
    <title>@yield('title')</title>
    <base href="/">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="msapplication-TileColor" content="#ffffff">
    <meta name="msapplication-TileImage" content="{{ url("img/favicon/ms-icon-144x144.png") }}">
    <meta name="theme-color" content="#ffffff">
    <link rel="apple-touch-icon" sizes="57x57" href="{{ url("img/favicon/apple-icon-57x57.png") }}">
    <link rel="apple-touch-icon" sizes="60x60" href="{{ url("img/favicon/apple-icon-60x60.png") }}">
    <link rel="apple-touch-icon" sizes="72x72" href="{{ url("img/favicon/apple-icon-72x72.png") }}">
    <link rel="apple-touch-icon" sizes="76x76" href="{{ url("img/favicon/apple-icon-76x76.png") }}">
    <link rel="apple-touch-icon" sizes="114x114" href="{{ url("img/favicon/apple-icon-114x114.png") }}">
    <link rel="apple-touch-icon" sizes="120x120" href="{{ url("img/favicon/apple-icon-120x120.png") }}">
    <link rel="apple-touch-icon" sizes="144x144" href="{{ url("img/faviconapple-icon-144x144.png") }}">
    <link rel="apple-touch-icon" sizes="152x152" href="{{ url("img/favicon/apple-icon-152x152.png") }}">
    <link rel="apple-touch-icon" sizes="180x180" href="{{ url("img/favicon/apple-icon-180x180.png") }}">
    <link rel="icon" type="image/png" sizes="192x192" href="{{ url("img/favicon/android-icon-192x192.png") }}">
    <link rel="icon" type="image/png" sizes="32x32" href="{{ url("img/favicon/favicon-32x32.png") }}">
    <link rel="icon" type="image/png" sizes="96x96" href="{{ url("img/favicon/favicon-96x96.png") }}">
    <link rel="icon" type="image/png" sizes="16x16" href="{{ url("img/favicon/favicon-16x16.png") }}">
    <link rel="manifest" href="{{ url("img/favicon/manifest.json") }}">
    <link rel="stylesheet" type="text/css" href="{{ getenv('APP_ENV_CUSTOM') == 'production' ? '/css/all.css' : elixir("css/all.css") }}">
    <link rel="stylesheet" type="text/css" href="//cdnjs.cloudflare.com/ajax/libs/cookieconsent2/3.0.3/cookieconsent.min.css" />
    <script src="//cdnjs.cloudflare.com/ajax/libs/cookieconsent2/3.0.3/cookieconsent.min.js"></script>
    <script>
        window.addEventListener("load", function(){
            window.cookieconsent.initialise({
                "palette": {
                    "popup": {
                        "background": "#e7e7e7",
                        "text": "#000000"
                    },
                    "button": {
                        "background": "#3b8686",
                        "text": "#ffffff"
                    }
                },
                "theme": "edgeless",
                "content": {
                    "href": "/imprint"
                }
            })});
    </script>
    <script src="{{ getenv('APP_ENV_CUSTOM') == 'production' ? '/js/all.js' : elixir("js/all.js") }}"></script>
    <script src='https://www.google.com/recaptcha/api.js' async defer></script>
</head>

<body>
@section('nav')
<nav class="wrap navbar navbar-default navbar-fixed-top" id="navbar">
    <div class="container">
        <!-- Brand and toggle get grouped for better mobile display -->
        <div class="navbar-header">
            <a name="top"></a>
            <button type="button" class="navbar-toggle collapsed" data-toggle="collapse"
                    data-target="#navbar-collapse" aria-expanded="false">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
            <a class="navbar-brand hidden-sm" href="/#top">
                {!! Html::image("img/logo_transparent_white.png", 'Web at Speed') !!}
            </a>
        </div>
        <div class="collapse navbar-collapse" id="navbar-collapse">
            <ul class="nav navbar-nav">
                @if(isset($isHomepage) ? $isHomepage : false)
                    <li><a href="#dev">Development <span class="sr-only">(current)</span></a></li>
                    <li><a href="#startup">Start-Up</a></li>
                    <li><a href="#usability">Usability</a></li>
                    <li><a href="#devices">Devices</a></li>
                    <li><a href="#customers">Customers</a></li>
                    <li><a href="#headhunters">Headhunters</a></li>
                    <li><a href="#contact">Content</a></li>
                @else
                    <li><a href="/#dev">Development <span class="sr-only">(current)</span></a></li>
                    <li><a href="/#startup">Start-Up</a></li>
                    <li><a href="/#usability">Usability</a></li>
                    <li><a href="/#devices">Devices</a></li>
                    <li><a href="/#customers">Customers</a></li>
                    <li><a href="/#headhunters">Headhunters</a></li>
                    <li><a href="/#contact">Content</a></li>
                @endif
            </ul>
        </div>
    </div>
</nav>
@show
<main>
    @yield('content')
</main>
<footer class="wrap footer">
    <div class="container">
        <div class="row">
            <div class="col-md-4">
                {!! Html::image("img/logo_transparent_black.png", 'Web at Speed', array('id' => 'footerlogo')) !!}
                <br/><br/>
                &copy; 2013-{{ date('Y') }} Web at Speed. All rights reserved.
            </div>
            <div class="col-md-4">
                <h4>Follow Us</h4>
                <ul class="list-inline">
                    <li>
                        <a href="http://xing.to/webatspeed"><i class="fa fa-xing-square fa-3x"></i></a>
                    </li>
                    <li>
                        <a href="https://linkedin.com/in/torstenkrohn"><i class="fa fa-linkedin-square fa-3x"></i></a>
                    </li>
                    <li>
                        <a href="https://www.facebook.com/webatspeed/"><i class="fa fa-facebook-square fa-3x"></i></a>
                    </li>
                    <li>
                        <a href="https://twitter.com/webatspeed"><i class="fa fa-twitter-square fa-3x"></i></a>
                    </li>
                </ul>
            </div>
            <div class="col-md-4">
                <h4>Contact Us</h4>
                <ul class="list-unstyled">
                    <li>Web at Speed GmbH<br/>Rosenfelder Ring 13, 10315 Berlin</li>
                    <li>torsten.krohn (at) webatspeed.com</li>
                    <li>+49 30 91524052</li>
                </ul>
                <ul class="list-unstyled">
                    <li>
                        <a href="javascript:window.location.href='/imprint'">Impressum / Imprint</a>
                    </li>
                    <li>
                        <a href="javascript:window.location.href='/imprint'">Datenschutz / Privacy</a>
                    </li>
                </ul>
                <a class="btn btn-default pull-right" href="#top" role="button">
                    <i class="fa fa-chevron-up"></i>
                </a>
            </div>
        </div>
    </div>
</footer>
</body>
</html>
