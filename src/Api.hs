{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE DeriveAnyClass    #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators     #-}

module Api where

import           Data.Aeson
import           Lucid
import           Network.HTTP.Client       (Manager, defaultManagerSettings,
                                            newManager)
import           Network.HTTP.ReverseProxy
import           Network.Wai
import           Network.Wai.Handler.Warp
import           Servant
import           Servant.HTML.Lucid

import           GHC.Generics

type API
    = Get '[HTML] (Html ())
    :<|> "cat" :> Get '[JSON] Cat
    :<|> "dog" :> Get '[JSON] Dog

newtype Cat = Cat { cat :: String }

instance ToJSON Cat where
    toJSON (Cat mew) =
        object [ "cat" .= mew ]

newtype Dog = Dog { dog :: String }
    deriving (Generic, ToJSON)

server :: Server API
server = pure index :<|> cats :<|> dogs
  where
    cats = pure (Cat { cat = "mrowl" })
    dogs = pure (Dog { dog = "zzzzzzzz" })
    index = p_ $ do
        "You can get either a "
        a_ [href_ "cat"] "cat"
        " or a "
        a_ [href_ "dog"] "dog"
        "."

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
