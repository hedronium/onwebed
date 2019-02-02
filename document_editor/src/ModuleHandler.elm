module ModuleHandler exposing (hasModule, modules)


modules : List String
modules =
    [ "biu"
    ]


hasModule : String -> Bool
hasModule name =
    List.any
        (\module_name ->
            if module_name == name then
                True

            else
                False
        )
        modules
