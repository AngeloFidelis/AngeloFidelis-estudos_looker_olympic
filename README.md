# Estudos looker
Esse projeto conta com dois arquivos de viewer: **athletes** (com informações sobre cada atleta) e **medals** (onde mostra as medalhes que cada atleta ganhou)

Além disso, dentro do arquivo model, há a junção do arquivo **athletes** com o arquivo **medals** através desse código:
```sql
explore: athletes {
  join: medals {
    type: left_outer
    sql_on: ${athletes.id} = ${medals.id_athlete} ;;
    relationship: one_to_many
  }
}
```
onde:
- `explore: athletes {}`: é uma definição que cria uma exploração (tipo um ponto de partida) para os usuários analisarem os dados chamada athletes (mesmo nome da view, isso significa que todos os dados presente no arquivo **athletes** irá aparecer no explorer **athletes**)
- `join: medals {}`: especifica uma junção com outra tabela ou visualização, onde nesse caso, vamos juntar a tabela **athletes** com a tabela **models**
- `type: left_outer`: especifica o tipo de junção usado, onde nesse caso, todos os registros da tabela athletes serão retornados, junto com os registros correspondentes da tabela medals, se existirem
- `sql_on: ${athletes.id} = ${medals.id_athlete} ;;`: esta linha define a condição para a junção, onde serão retornados os campo quando o id da tabela **athletes** for igual ao campo **id_athlete** da tabela medals.
- `relationship: one_to_many`: especifica a natureza da relação entre as duas tabelas, indicando que um registro na tabela athletes pode corresponder a muitos registros na tabela medals.

<details>
  <summary>Componentes LookML</summary>

### Mudanças iniciais
1. Dentro do arquivo **models**, foi criado um componente `set` para realizar um drill_fields dentro da medida count, como no código abaixo:
    ```sql
    measure: count {
        type: count
        drill_fields: [show_details*]
    }
    set: show_details {
        fields: [
        athlete_name,
        country,
        medal_type,
        discipline,
        athletes.height,
        athletes.age
        ]
    }
    ```
    a. Isso permite especifica um conjunto de campos para detalhamento. Quando um usuário clicar para detalhar a medida count na interface do Looker, ele verá os campos definidos no conjunto show_details.

2. Dentro do arquivo **models**, foi criando dois componentes: uma dimensão escondida do tipo `yesno` que retorna como verdadeiro (Yes) quandos os países forem igual ao "United States of America"; e uma medida do tipo `count` que conta as medalhas ganhas por atletas dos Estados Unidos aplicando um filtro para considerar apenas registros onde o país é "United States of America". E por fim permite detalhamento para ver mais informações sobre os atletas e suas medalhas.
    ```sql
    dimension: medal_usa_yesno{
        type: yesno
        hidden: yes
        sql: ${country} = "United States of America" ;;
    }

    measure: total_usa_medal {
        type: count
        label: "United States medals"
        --sql: ${medal_type} ;; o tipo `count` nao usa `sql`
        filters: [medal_usa_yesno: "Yes"]
        drill_fields: [athlete_name,country,medal_type,discipline]
    }
    ```

3. Dentro do arquivo **athletes.view**, foi criado uma dimensão do tipo `tier` que serve para categorizar algo. Nesse caso, foi usado para categorizar as idades de todos os participantes
    ```sql
    dimension: age_tier {
        type: tier
        tiers: [18, 25, 35, 45, 55, 65] --Define os limites dos intervalos (tiers)
        style: integer
        sql: ${age} ;;
    }
    ```

3. Dentro do arquivo **athletes.view**, foi criado uma dimensão do tipo number, que retorna a idade dos participantes (no código, é usado a data atual para fazer a diferença de idade, e não a data de quando os jogos foram realizados - 2021). Apesar de já ter uma coluna no banco de dados que mostra a idade dos jogadores, esse componente foi utilizado para praticar o trecho `DATE_DIFF(CURRENT_DATE, ${birth_date}, YEAR)`
    ```sql
    dimension: age_diff {
        type: number
        sql: DATE_DIFF(CURRENT_DATE, ${birth_date},YEAR) ;;
    }
    ```



</details>

<details>
  <summary>Dashboard criado</summary>

</details>

<details>
  <summary>Dúvidas</summary>

</details>
