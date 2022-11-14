/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('or_per_lug', {
		id_or_per_lug: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_or_per_lug::regclass)",
			primaryKey: true
		},
		fk_origen_persona_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: 'origen_persona',
				key: 'id_origen_persona'
			}
		},
		fk_persona_rol_pertenencia_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: 'persona_rol_pertenencia',
				key: 'id_persona_rol_pertenencia'
			}
		},
		fk_lugar_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'lugar',
				key: 'id_lugar'
			}
		},
		precision_lugar: {
			type: DataTypes.STRING,
			allowNull: true
		}
	}, {
		tableName: 'or_per_lug',
		timestamps: false
	});
};
