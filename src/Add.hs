module Add where
import Card
import Decks
import Display
import Text.Printf(printf)
import qualified Input
data AddAction = NewDeck | ToDeck deriving (Show, Eq)

instance Display AddAction where
    display addAct = show addAct

addLoop :: [Deck] -> IO [Deck]
addLoop decks = do
    addAction <- getAddAction decks
    runAddAction addAction decks

runAddAction :: Maybe AddAction -> [Deck] -> IO [Deck]
runAddAction addAction decks
    | addAction == Just NewDeck = newDeck decks
    | addAction == Just ToDeck  = toDeck decks
    | addAction == Nothing      = return decks

newDeck :: [Deck] -> IO [Deck]
newDeck decks = do
    printf $ "Please input the name of the new deck" ++ "\n"
    deckName <- getLine
    case deckName of 
        "" -> do
                return decks
        _  -> if any (\deck -> dName deck == deckName) decks
                then do
                  printf $ "Invalid input, already a deck with that name" ++ "\n"
                  newDeck decks
                else 
                  return $ addDeckWithName deckName decks

addDeckWithName :: String -> [Deck] -> [Deck]
addDeckWithName name decks = decks ++ [Deck {dCards = [], dName = name}]

toDeck :: [Deck] -> IO [Deck]
toDeck decks = do
    chosenDeck <- Input.getUserChoice $ decks
    case chosenDeck of
        Just deck -> do
                        deckWithNewItems <- toDeckLoop deck
                        let newDecks = replaceDeckNamed (dName deck) deckWithNewItems decks
                        return $ newDecks
        Nothing -> return decks


toDeckLoop :: Deck -> IO Deck
toDeckLoop deck = do
    printf $ "Please input the question, enter to stop adding" ++ "\n"
    question <- getLine
    case question of 
        "" -> do
                printf $ "You wish to stop adding" ++ "\n"
                return deck
        _  -> do
                printf $ "Please input the answer" ++ "\n"
                answer <- getLine
                case answer of
                    "" -> do
                        printf $ "You wish to stop adding" ++ "\n"
                        return deck
                    _  -> do
                        let card = newCard question answer
                        toDeckLoop (addCardToDeck card deck)

getAddAction :: [Deck] -> IO (Maybe AddAction)
getAddAction decks
    | null decks = return $ Just NewDeck
    | otherwise = Input.getUserChoice allAddActions

allAddActions :: [AddAction]
allAddActions = [NewDeck, ToDeck]