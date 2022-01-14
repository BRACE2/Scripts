function render(varargin)
    python = 'python ';
    install_path = fileparts(mfilename('fullpath'));
    if strcmp(varargin{1},"--install")
       [status, output] = system( ...
           [python ' -m pip install --upgrade pip'], '-echo'...
       );
       [status, output] = system( ...
           [python fullfile(install_path,'render.py') ...
           ' --install'], '-echo'...
       );
       return
    end
    [status, output] = system(strjoin({'python -m render', strjoin(varargin)}));
    if strcmp(varargin{1},"-h") || strcmp(varargin{1},"--help")
      output
    %elseif ~status
    %  GroundMotion = jsondecode(output);
    else
     status
     output
    end
end
