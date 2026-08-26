function message = validate_path(dir_path, action)
    % VALIDATE_PATH Checks for directory existence and performs an action.

    is_dir = (exist(dir_path, 'dir') == 7);

    switch lower(action)

        case 'error_if_missing'
            if ~is_dir
                error('CORE:PATH_MISSING', ...
                      'Directory "%s" was not found.', dir_path);
            end

            message = sprintf( ...
                '  -> Directory verified: %s', dir_path);

        case 'create_if_missing'
            if ~is_dir
                [status, msg] = mkdir(dir_path);

                if status
                    message = sprintf( ...
                        '  -> Created missing directory: %s', dir_path);
                else
                    error('CORE:MKDIR_FAILED', ...
                          'Could not create "%s". Reason: %s', ...
                          dir_path, msg);
                end
            else
                message = sprintf( ...
                    '  -> Directory verified: %s', dir_path);
            end

        otherwise
            error('CORE:USAGE_ERROR', ...
                  'Action "%s" not recognized.', action);
    end
end
