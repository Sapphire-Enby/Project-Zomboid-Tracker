
In order to ensure this performs properly 
make a symbolic link to Project-Zomboid-Tracker's output folder 
in web's root folder here under the same name

"""powershell
PS C:\WINDOWS\system32> New-Item -ItemType SymbolicLink -Path "C:\Users\lenti\Desktop\web\output\"-Target "C:\Users\lenti\Zomboid\mods\Project-Zomboid-Tracker\output\"
"""