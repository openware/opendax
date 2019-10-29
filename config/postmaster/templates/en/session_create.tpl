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
                We detected a login to your account.
            </p>

            <p class="text">IP Address: {{ .record.user_ip }}</p>
            <p class="text">User-agent: {{ .record.user_agent }}</p>

            <p class="text">If this was you, please disregard this email.</p>

            <p class="text">If this wasn't you, please change your passwords immediately, as someone else may be accessing your account.</p>
        </div>
    </div>
</body>

</html>
