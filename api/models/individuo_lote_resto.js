/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('individuo_lote_resto', {
		id_individuo_resto: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_individuo_resto::regclass)",
			primaryKey: true
		},
		fk_resto_variable: {
			type: DataTypes.STRING,
			allowNull: true,
			references: {
				model: 'resto',
				key: 'variable'
			}
		},
		fk_especie_nombre: {
			type: DataTypes.STRING,
			allowNull: true,
			references: {
				model: 'especie',
				key: 'nombre'
			}
		},
		fk_individuo_arqueologico_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'individuo_arqueologico',
				key: 'id_individuo_arqueologico'
			}
		},
		fk_entierro: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'entierro',
				key: 'id_entierro'
			}
		},
		cantidad_lote: {
			type: DataTypes.INTEGER,
			allowNull: true
		},
		fk_lote_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'lote',
				key: 'id_lote'
			}
		}
	}, {
		tableName: 'individuo_lote_resto',
		timestamps: false
	});
};
