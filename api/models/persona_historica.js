/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('persona_historica', {
		id_persona_historica: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_persona_historica::regclass)",
			primaryKey: true
		},
		nombre: {
			type: DataTypes.STRING,
			allowNull: false
		},
		genero: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_persona_historica: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'persona_historica',
				key: 'id_persona_historica'
			}
		},
		fk_individuo_arqueologico_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'individuo_arqueologico',
				key: 'id_individuo_arqueologico'
			}
		}
	}, {
		tableName: 'persona_historica',
		timestamps: false
	});
};
