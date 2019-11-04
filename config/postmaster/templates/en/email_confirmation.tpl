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

        .confirmation-button {
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
                Use this unique link to confirm your email {{ .record.user.email }}
            </p>
            <div class="confirmation-button">
                <a href="{{ .record.domain }}/accounts/confirmation?confirmation_token={{ .record.token }}&lang=en">Confirm</a>
            </div>
        </div>
    </div>
</body>

</html>
