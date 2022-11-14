/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('estado_rel_individuo_arqueologico', {
		fk_estado_tipo_cons_repre: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'estado',
				key: 'tipo_cons_represen'
			}
		},
		fk_estado_elemento: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true
		},
		fk_individuo_arqueologico_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: 'individuo_arqueologico',
				key: 'id_individuo_arqueologico'
			}
		},
		valor: {
			type: DataTypes.STRING,
			allowNull: false
		}
	}, {
		tableName: 'estado_rel_individuo_arqueologico',
		timestamps: false
	});
};
