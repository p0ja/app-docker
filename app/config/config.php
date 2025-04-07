<?php

declare(strict_types=1);

class Config
{
    public function __construct(
        private array $dbSettings = [],
    ) {
        $this->dbSettings = [
            'db_host'   => getenv('DB_HOST'),
            'db_name'   => getenv('DB_NAME'),
            'db_user'   => getenv('DB_USER'),
            'db_pass'   => getenv('DB_PASS'),
        ];
    }

    public function getConfig(): array
    {
        return [
            'dbParams' => $this->dbSettings,
        ];
    }
}