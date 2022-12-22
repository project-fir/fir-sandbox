module Evergreen.V54.EditorModel exposing (..)

import Array
import ContextMenu
import Debounce
import Evergreen.V54.EditorMsg
import Evergreen.V54.History
import Evergreen.V54.Vim
import Evergreen.V54.Window
import RollingList


type alias Snapshot =
    { lines : Array.Array String
    , cursor : Evergreen.V54.EditorMsg.Position
    , selection : Evergreen.V54.EditorMsg.Selection
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
    , cursor : Evergreen.V54.EditorMsg.Position
    , window : Evergreen.V54.Window.Window
    , hover : Evergreen.V54.EditorMsg.Hover
    , selection : Evergreen.V54.EditorMsg.Selection
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
    , history : Evergreen.V54.History.History Snapshot
    , contextMenu : ContextMenu.ContextMenu Evergreen.V54.EditorMsg.Context
    , autoLineBreak : AutoLineBreak
    , debugOn : Bool
    , topLine : Int
    , wrapOption : Evergreen.V54.EditorMsg.WrapOption
    , clipboard : String
    , searchTerm : String
    , searchResults : RollingList.RollingList Evergreen.V54.EditorMsg.Selection
    , searchResultIndex : Int
    , showSearchPanel : Bool
    , canReplace : Bool
    , replacementText : String
    , viewMode : ViewMode
    , indentationOffset : Int
    , helpState : HelpState
    , editMode : EditMode
    , vimModel : Evergreen.V54.Vim.VimModel
    , devModeOn : Bool
    }
