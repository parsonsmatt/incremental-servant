{-# LANGUAGE DataKinds       #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators   #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}

module Api where

import Data.Aeson
import Network.HTTP.ReverseProxy
import Network.HTTP.Client (Manager, defaultManagerSettings, newManager)
import Network.Wai
import Network.Wai.Handler.Warp
import Servant

import GHC.Generics

type API
    = "cat" :> Get '[JSON] Cat
    :<|> "dog" :> Get '[JSON] Dog

newtype Cat = Cat { cat :: String }

instance ToJSON Cat where
    toJSON (Cat mew) =
        object [ "cat" .= mew ]

newtype Dog = Dog { dog :: String }
    deriving (Generic, ToJSON)

server :: Server API
server = cats :<|> dogs
  where
    cats = pure (Cat { cat = "mrowl" })
    dogs = pure (Dog { dog = "zzzzzzzz" })

api :: Proxy (API :<|> Raw)
api = Proxy

app :: Manager -> Application
app manager =
    serve api $ server :<|> waiProxyTo forwardRequest defaultOnExc manager

forwardRequest :: Request -> IO WaiProxyResponse
forwardRequest _ =
    pure . WPRProxyDest . ProxyDest "127.0.0.1" $ 4567

startApp :: IO ()
startApp = do
    manager <- newManager defaultManagerSettings
    run 8080 (app manager)
