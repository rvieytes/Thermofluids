function bootstrap_buffer = validate_directories(dirs, bootstrap_buffer)
    % VALIDATE_DIRECTORIES Validates a collection of directories.
    %
    % Parameters:
    %   dirs:             Nx2 cell array {path, action}
    %   bootstrap_buffer: Bootstrap log buffer.
    %
    % Returns:
    %   bootstrap_buffer: Updated bootstrap log buffer.

    for i = 1:size(dirs, 1)

        dir_path = dirs{i, 1};
        action   = dirs{i, 2};

        command = sprintf( ...
            'validate_path(''%s'', ''%s'');', ...
            dir_path, action);

        new_entries = log_function(command, 1);
        bootstrap_buffer = [bootstrap_buffer, new_entries];

    end
end
