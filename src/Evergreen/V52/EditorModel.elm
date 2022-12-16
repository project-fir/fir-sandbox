module Evergreen.V52.EditorModel exposing (..)

import Array
import ContextMenu
import Debounce
import Evergreen.V52.EditorMsg
import Evergreen.V52.History
import Evergreen.V52.Vim
import Evergreen.V52.Window
import RollingList


type alias Snapshot =
    { lines : Array.Array String
    , cursor : Evergreen.V52.EditorMsg.Position
    , selection : Evergreen.V52.EditorMsg.Selection
    }


type AutoLineBreak
    = AutoLineBreakON
    | AutoLineBreakOFF


type ViewMode
    = Light
    | Dark


type HelpState
    = HelpOn
    | HelpOff


type VimMode
    = VimNormal
    | VimInsert


type EditMode
    = StandardEditor
    | VimEditor VimMode


type alias EditorModel =
    { lines : Array.Array String
    , cursor : Evergreen.V52.EditorMsg.Position
    , window : Evergreen.V52.Window.Window
    , hover : Evergreen.V52.EditorMsg.Hover
    , selection : Evergreen.V52.EditorMsg.Selection
    , selectedText : Array.Array String
    , selectedString : Maybe String
    , width : Float
    , height : Float
    , fontSize : Float
    , lineHeight : Float
    , verticalScrollOffset : Int
    , lineNumberToGoTo : String
    , viewLineNumbersOn : Bool
    , debounce : Debounce.Debounce String
    , history : Evergreen.V52.History.History Snapshot
    , contextMenu : ContextMenu.ContextMenu Evergreen.V52.EditorMsg.Context
    , autoLineBreak : AutoLineBreak
    , debugOn : Bool
    , topLine : Int
    , wrapOption : Evergreen.V52.EditorMsg.WrapOption
    , clipboard : String
    , searchTerm : String
    , searchResults : RollingList.RollingList Evergreen.V52.EditorMsg.Selection
    , searchResultIndex : Int
    , showSearchPanel : Bool
    , canReplace : Bool
    , replacementText : String
    , viewMode : ViewMode
    , indentationOffset : Int
    , helpState : HelpState
    , editMode : EditMode
    , vimModel : Evergreen.V52.Vim.VimModel
    , devModeOn : Bool
    }
