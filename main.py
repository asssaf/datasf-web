import click

@click.group()
def cli():
    """A CLI app that executes a rest api which performs a query with multiple arguments."""
    pass

@cli.command()
@click.option('--param', multiple=True, help='Query parameters in key=value format.')
def query(param):
    """Execute a query with multiple arguments."""
    query_params = {}
    for p in param:
        if '=' not in p:
            raise click.ClickException(f"Invalid parameter format: '{p}'. Use key=value.")
        key, value = p.split('=', 1)
        query_params[key] = value
    
    click.echo(f"Querying with arguments: {query_params}")

if __name__ == '__main__':
    cli()
