/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('origen_persona', {
		id_origen_persona: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_origen_persona::regclass)",
			primaryKey: true
		},
		nombre: {
			type: DataTypes.STRING,
			allowNull: true
		},
		descripcion: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_origen_persona_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'origen_persona',
				key: 'id_origen_persona'
			}
		}
	}, {
		tableName: 'origen_persona',
		timestamps: false
	});
};
