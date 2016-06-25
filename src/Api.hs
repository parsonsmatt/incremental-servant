{-# LANGUAGE DataKinds       #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators   #-}
module Api where

import Network.HTTP.ReverseProxy
import Network.HTTP.Client (Manager, defaultManagerSettings, newManager)
import Network.Wai
import Network.Wai.Handler.Warp
import Servant

type API = Raw

forwardRequest :: Request -> IO WaiProxyResponse
forwardRequest _ = 
    pure . WPRProxyDest . ProxyDest "127.0.0.1" $ 4567

app :: Manager -> Application
app manager =
    waiProxyTo forwardRequest defaultOnExc manager

startApp :: IO ()
startApp = do
    manager <- newManager defaultManagerSettings
    run 8080 (app manager)
