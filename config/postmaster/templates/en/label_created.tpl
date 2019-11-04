<html>

<head>
    <style>
        .main-block {
            border-radius: 3px;
            box-shadow: 0px 1px 5px rgba(0, 0, 0, 0.1);
            height: auto;
            width: 560px;
            margin: 50px auto;
        }

        .logo {
            border-bottom: 1px solid #F3F3F3;
            height: 71px;
            line-height: 71px;
            padding-top: 11px;
            text-align: center;
        }

        .logo-img {
            height: 50px;
            width: 145px;
        }

        .content {
            padding: 21px 30px 36px 30px;
            text-align: center;
        }

        .title {
            color: black;
            font-family: Lato;
            font-style: normal;
            font-weight: bold;
            font-size: 14px;
            line-height: 17px;
        }

        .text {
            color: black;
            font-family: Lato;
            font-style: normal;
            font-weight: normal;
            font-size: 14px;
            line-height: 17px;
            margin-bottom: 37px;
        }

        .reset-button {
            background: #3C78E0;
            margin-left: 172px;
            height: 40px;
            width: 163px;
        }

        a {
            color: #FFFFFF;
            font-family: Roboto;
            font-style: normal;
            font-weight: normal;
            font-size: 16px;
            line-height: 40px;
            display: inline-block;
            align-items: center;
            text-align: center;
            text-decoration: none;
            height: 40px;
            width: 163px;
        }
    </style>
</head>

<body>
    <div class="main-block">
        <div class="logo">
            <img class="logo-img" src="https://storage.googleapis.com/openware-assets/logo.png" />
        </div>
        <div class="content">
            <p class="title">Hello!</p>

            <p class="text">
                We detected an update of your account details.
            </p>

            <p class="text">
            {{ if eq .record.key "phone" }}
                Your phone number was {{ .record.value }}.
            {{ end }}
            {{ if eq .record.key "profile" }}
                Your user profile was {{ .record.value }}.
            {{ end }}
            {{ if eq .record.key "document" }}
                Your main document was {{ .record.value }}.
            {{ end }}
            </p>

            <p class="text">Level: {{ .record.user.level }}</p>
            <p class="text">State: {{ .record.user.state }}</p>
        </div>
    </div>
</body>

</html>
